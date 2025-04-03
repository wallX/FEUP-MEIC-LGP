# Authentication API Endpoints

## Base URL
```
/api/auth
```

---

## **1. Login**
### **Endpoint:**
```
POST /api/auth/login
```

### **Headers:**
None

### **Request Body:**
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

### **Response:**
```json
{
  "token": "<JWT_TOKEN>",
  "refresh": "<REFRESH_TOKEN>",
  "refreshTTL": 1712345678
}
```

---

## **2. Logout**
### **Endpoint:**
```
POST /api/auth/logout
```

### **Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Refresh-Token: <REFRESH_TOKEN>
```

### **Request Body:**
None

### **Response:**
```json
{
  "message": "Logged out successfully"
}
```

---

## **3. Refresh Token**
### **Endpoint:**
```
POST /api/auth/refresh
```

### **Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Refresh-Token: <REFRESH_TOKEN>
```

### **Request Body:**
None

### **Response:**
```json
{
  "token": "<NEW_JWT_TOKEN>",
  "refresh": "<NEW_REFRESH_TOKEN>",
  "refreshTTL": 1712345678
}
```

---

## **4. Authenticate User and Role Check**
### **Endpoint:**
```
GET /api/auth
```

### **Headers:**
```
Authorization: Bearer <JWT_TOKEN>
User-Role: <ROLE>
```

### **Request Body:**
None

### **Response (Success):**
```json
"Role <ROLE> access granted to <USER_ID>"
```

### **Response (Failure - Invalid Role Header):**
```json
{
  "error": "Invalid role header format"
}
```

### **Response (Failure - Insufficient Permissions):**
```json
{
  "error": "Insufficient permissions"
}
```

---

## Notes
- `<JWT_TOKEN>`: JWT token obtained from login.
- `<REFRESH_TOKEN>`: Refresh token obtained from login.
- `<ROLE>`: Expected role for authentication (e.g., `Admin`, `User`).

