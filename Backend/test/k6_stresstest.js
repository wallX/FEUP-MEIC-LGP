import http from 'k6/http';
import { check, sleep } from 'k6';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

const BASE_URL = 'http://192.168.3.100';

export let options = {
    stages: [
        { duration: '1m', target: 500 },
        { duration: '5m', target: 1000 },
        { duration: '1m', target: 0 },
    ],
};

export default function () {
    const email = `user_${uuidv4()}@mail.com`;
    const password = 'password123';
    const name = 'Stress User';
    const dummySize = 5 * 1024 * 1024; // 5MB
    const dummyFilename = `file_${uuidv4()}.mp4`;

    // 1. Register
    const registerRes = http.post(`${BASE_URL}/api/auth/register`, JSON.stringify({
        email, name, password,
    }), {
        headers: { 'Content-Type': 'application/json' },
    });
    check(registerRes, { 'registered': (r) => r.status === 200 || r.status === 201 });

    // 2. Login
    const loginRes = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
        email, password,
    }), {
        headers: { 'Content-Type': 'application/json' },
    });
    check(loginRes, { 'logged in': (r) => r.status === 200 });

    const token = loginRes.json('token');
    check(token, { 'got token': (t) => !!t });

    // 3. Initiate Upload (Tus-compatible POST)
    const uploadInitRes = http.post(`${BASE_URL}/api/uploads`, null, {
        headers: {
            'Authorization': `Bearer ${token}`,
            'file_name': dummyFilename,
            'file_length': dummySize.toString(),
        },
    });

    check(uploadInitRes, {
        'upload initiated': (res) => res.status === 201 && res.headers['Location'],
    });

    const uploadUrl = uploadInitRes.headers['Location'];
    if (!uploadUrl) {
        console.error('No Location header returned for upload.');
        return;
    }

    // ⛔ SKIPPING PATCH CHUNKS — best done with custom client like your Rust code
    sleep(1);
}