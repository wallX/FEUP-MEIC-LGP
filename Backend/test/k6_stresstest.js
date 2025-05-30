import http from 'k6/http';
import { check, fail, sleep } from 'k6';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

const BASE_URL = 'http://192.168.3.100';
const LOGIN_REPEAT = 10;
const UPLOAD_REPEAT = 5;
const FILE_SIZE = 2 * 1024 * 1024; // 2MB
const CHUNK_SIZE = 512 * 1024;     // 512 KB

export const options = {
    scenarios: {
        user_flow: {
            executor: 'constant-arrival-rate',
            rate: 5, // 5 new users per second
            timeUnit: '1s',
            duration: '2m', // Total 600 users
            preAllocatedVUs: 100,
            maxVUs: 100,
        },
    },
};

export default function () {
    const email = `user_${uuidv4()}@mail.com`;
    const password = 'password123';
    const name = 'Stress User';
    const dummyFilename = `file_${uuidv4()}.mp4`;

    console.log(`👤 Starting user: ${email}`);

    // 1. Register
    const registerRes = http.post(`${BASE_URL}/api/auth/register`, JSON.stringify({
        email, name, password,
    }), {
        headers: { 'Content-Type': 'application/json' },
    });

    if (!(registerRes.status === 200 || registerRes.status === 201)) {
        console.error(`❌ Registration failed
Status: ${registerRes.status}
Body: ${registerRes.body}`);
        fail('Aborting: Registration failed.');
    }

    // 2. Login 10 times
    let token = '';
    for (let i = 0; i < LOGIN_REPEAT; i++) {
        const loginRes = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
            email, password,
        }), {
            headers: { 'Content-Type': 'application/json' },
        });

        if (loginRes.status !== 200) {
            console.error(`❌ Login ${i + 1} failed
Status: ${loginRes.status}
Body: ${loginRes.body}`);
            fail(`Aborting: Login ${i + 1} failed.`);
        }

        token = loginRes.json('token') || token;
        console.log(`🔐 Login ${i + 1} successful`);
        sleep(0.1);
    }

    // 3. Upload 5 files in PATCH chunks
    for (let j = 0; j < UPLOAD_REPEAT; j++) {
        const fileName = `${dummyFilename}_part${j}`;
        const uploadInitRes = http.post(`${BASE_URL}/api/uploads`, null, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'file_name': fileName,
                'file_length': FILE_SIZE.toString(),
            },
        });

        if (uploadInitRes.status !== 201 || !uploadInitRes.headers['Location']) {
            console.error(`❌ Upload init ${j + 1} failed
Status: ${uploadInitRes.status}
Body: ${uploadInitRes.body}`);
            fail(`Aborting: Upload init ${j + 1} failed.`);
        }

        const uploadURL = uploadInitRes.headers['Location'];
        console.log(`📤 Upload ${j + 1} started to ${uploadURL}`);

        // Simulate file content as a buffer filled with 'x'
        const chunk = new Array(CHUNK_SIZE).fill('x').join('');
        let offset = 0;

        while (offset < FILE_SIZE) {
            const remaining = FILE_SIZE - offset;
            const currentChunk = chunk.substring(0, Math.min(CHUNK_SIZE, remaining));

            const patchRes = http.patch(uploadURL, currentChunk, {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Tus-Resumable': '1.0.0',
                    'Upload-Offset': offset.toString(),
                    'Content-Type': 'application/offset+octet-stream',
                },
            });

            if (!patchRes.status || patchRes.status >= 400) {
                console.error(`❌ Chunk upload failed at offset ${offset}
Status: ${patchRes.status}
Body: ${patchRes.body}`);
                fail(`Upload failed during PATCH at offset ${offset}`);
            }

            offset += currentChunk.length;
            sleep(0.05); // Slight delay between chunks
        }

        console.log(`✅ Upload ${j + 1} complete!`);
        sleep(0.1);
    }
}