# Backend API Documentation

This document describes the API endpoints that the PPE Detection System expects from the backend.

## Base URL

```
https://api.example.com
```

> **Note**: Update this URL in `lib/services/api_service.dart` to point to your actual backend server.

## Authentication

All API requests must include a JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### 1. Analyze Image

Analyzes a captured image to detect PPE equipment and identify the worker.

**Endpoint**: `POST /analyze`

**Content-Type**: `multipart/form-data`

**Request Body**:
- `image`: Image file (JPEG/PNG)

**Example Request**:
```http
POST /analyze HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="image"; filename="capture.jpg"
Content-Type: image/jpeg

[binary image data]
------WebKitFormBoundary--
```

**Success Response**: `200 OK`

```json
{
  "name": "John Doe",
  "helmet": true,
  "vest": true,
  "timestamp": "2025-11-18T23:36:48.016Z"
}
```

**Response Fields**:
- `name` (string): Worker's name, or "Unknown" if not recognized
- `helmet` (boolean): Whether a safety helmet was detected
- `vest` (boolean): Whether a safety vest was detected
- `timestamp` (string): ISO 8601 timestamp of the detection

**Error Response**: `400 Bad Request`

```json
{
  "error": "Invalid image format"
}
```

**Error Response**: `401 Unauthorized`

```json
{
  "error": "Invalid or expired token"
}
```

---

### 2. Clock Event

Records a clock-in or clock-out event for a worker.

**Endpoint**: `POST /clock-event`

**Content-Type**: `application/json`

**Request Body**:

```json
{
  "workerName": "John Doe",
  "type": "clockIn",
  "timestamp": "2025-11-18T08:00:00.000Z",
  "helmet": true,
  "vest": true
}
```

**Request Fields**:
- `workerName` (string): Name of the worker
- `type` (string): Either "clockIn" or "clockOut"
- `timestamp` (string): ISO 8601 timestamp of the event
- `helmet` (boolean): Helmet status at time of event
- `vest` (boolean): Vest status at time of event

**Example Request**:
```http
POST /clock-event HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "workerName": "John Doe",
  "type": "clockIn",
  "timestamp": "2025-11-18T08:00:00.000Z",
  "helmet": true,
  "vest": true
}
```

**Success Response**: `200 OK` or `201 Created`

```json
{
  "success": true,
  "eventId": "evt_123456789",
  "message": "Clock in recorded successfully"
}
```

**Error Response**: `400 Bad Request`

```json
{
  "error": "Invalid request data"
}
```

**Error Response**: `401 Unauthorized`

```json
{
  "error": "Invalid or expired token"
}
```

---

## Example Backend Responses

### Scenario 1: Compliant Worker (All PPE Present)

```json
{
  "name": "John Doe",
  "helmet": true,
  "vest": true,
  "timestamp": "2025-11-18T08:00:00.000Z"
}
```

**App Behavior**: Shows "Clock In" or "Clock Out" button

---

### Scenario 2: Non-Compliant Worker (Missing Helmet)

```json
{
  "name": "Jane Smith",
  "helmet": false,
  "vest": true,
  "timestamp": "2025-11-18T08:00:00.000Z"
}
```

**App Behavior**: Shows "Reset" button with message "Missing safety helmet"

---

### Scenario 3: Unknown Worker

```json
{
  "name": "Unknown",
  "helmet": true,
  "vest": true,
  "timestamp": "2025-11-18T08:00:00.000Z"
}
```

**App Behavior**: Shows "Reset" button with message "Worker not recognized"

---

### Scenario 4: Non-Compliant Worker (Missing Both)

```json
{
  "name": "Bob Wilson",
  "helmet": false,
  "vest": false,
  "timestamp": "2025-11-18T08:00:00.000Z"
}
```

**App Behavior**: Shows "Reset" button with message "Missing helmet and vest"

---

## Testing the Integration

### Using cURL

#### Test Analyze Endpoint:

```bash
curl -X POST https://api.example.com/analyze \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "image=@/path/to/image.jpg"
```

#### Test Clock Event Endpoint:

```bash
curl -X POST https://api.example.com/clock-event \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "workerName": "John Doe",
    "type": "clockIn",
    "timestamp": "2025-11-18T08:00:00.000Z",
    "helmet": true,
    "vest": true
  }'
```

### Using Postman

1. Create a new POST request to `/analyze`
2. Set Authorization to "Bearer Token" and paste your JWT
3. In Body tab, select "form-data"
4. Add key "image" with type "File"
5. Upload an image file
6. Send the request

---

## Error Handling

The app handles the following error scenarios:

1. **Network Error**: Shows error message and returns to camera
2. **Timeout**: Shows timeout message after 30 seconds
3. **Invalid Response**: Shows parsing error and returns to camera
4. **401 Unauthorized**: Token expired or invalid
5. **500 Server Error**: Backend error

---

## Mock Backend for Development

For development and testing, you can create a mock server that returns sample responses:

### Node.js Example (Express)

```javascript
const express = require('express');
const multer = require('multer');
const app = express();
const upload = multer();

app.use(express.json());

// Middleware to check JWT
app.use((req, res, next) => {
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
});

// Analyze endpoint
app.post('/analyze', upload.single('image'), (req, res) => {
  // Simulate processing delay
  setTimeout(() => {
    res.json({
      name: 'John Doe',
      helmet: true,
      vest: true,
      timestamp: new Date().toISOString()
    });
  }, 2000);
});

// Clock event endpoint
app.post('/clock-event', (req, res) => {
  console.log('Clock event:', req.body);
  res.json({
    success: true,
    eventId: `evt_${Date.now()}`,
    message: `${req.body.type} recorded successfully`
  });
});

app.listen(3000, () => {
  console.log('Mock API server running on http://localhost:3000');
});
```

Run with: `node server.js`

Then update the base URL in the app:
```dart
static const String _baseUrl = 'http://localhost:3000';
```

> **Note**: For Android emulator, use `http://10.0.2.2:3000` instead of `localhost`

---

## Security Considerations

1. **HTTPS Only**: Use HTTPS in production
2. **JWT Validation**: Validate JWT tokens on every request
3. **Rate Limiting**: Implement rate limiting to prevent abuse
4. **Image Validation**: Validate image format and size
5. **CORS**: Configure CORS headers if web app is involved
6. **Input Sanitization**: Sanitize all input data

---

## Support

For backend implementation questions, contact the backend development team.
