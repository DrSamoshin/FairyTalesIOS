# API Errors Documentation

This document describes all possible errors that can be returned by the Fairy Tales Backend API endpoints.

## Error Response Format

All error responses follow this standard format:

```json
{
  "success": false,
  "message": "Error description",
  "errors": ["Detailed error message"],
  "error_code": "ERROR_CODE"
}
```

## Common HTTP Status Codes

- **200** - Success
- **400** - Bad Request (validation errors, business logic errors)
- **401** - Unauthorized (authentication required or failed)
- **403** - Forbidden (access denied)
- **404** - Not Found (resource doesn't exist)
- **422** - Unprocessable Entity (validation errors)
- **500** - Internal Server Error

## Authentication Endpoints

### POST `/api/v1/auth/register/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 400 | `USER_EXISTS` | User already exists | Email is already registered |
| 422 | - | Validation Error | Missing or invalid fields (name, email, password) |
| 500 | `INTERNAL_ERROR` | Registration failed | Server error during user creation |

**Example Error Response:**
```json
{
  "success": false,
  "message": "User already exists",
  "errors": ["Email is already registered"],
  "error_code": "USER_EXISTS"
}
```

### POST `/api/v1/auth/login/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `USER_NOT_FOUND` | User not found | No account found with this email |
| 401 | `INVALID_PASSWORD` | The password you entered is incorrect | Password does not match |
| 422 | - | Validation Error | Missing or invalid email/password format |
| 500 | `INTERNAL_ERROR` | Authentication failed | Server error during authentication |

**Example Error Responses:**
```json
{
  "success": false,
  "message": "User not found",
  "errors": ["No account found with this email"],
  "error_code": "USER_NOT_FOUND"
}
```

```json
{
  "success": false,
  "message": "The password you entered is incorrect",
  "errors": ["Password does not match"],
  "error_code": "INVALID_PASSWORD"
}
```

### POST `/api/v1/auth/apple-signin/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 400 | `INVALID_APPLE_CREDENTIALS` | Invalid Apple credentials | Apple ID verification failed |
| 422 | - | Validation Error | Missing or invalid Apple sign-in data |
| 500 | `INTERNAL_ERROR` | Apple Sign In failed | Server error during Apple authentication |

### POST `/api/v1/auth/refresh/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `TOKEN_EXPIRED` | Could not validate credentials | Token is expired or invalid |
| 401 | `UNAUTHORIZED` | User not found | User associated with token doesn't exist |

## User Profile Endpoints

### GET `/api/v1/user/profile/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `UNAUTHORIZED` | Could not validate credentials | Invalid or missing authorization token |
| 401 | `TOKEN_EXPIRED` | Could not validate credentials | Token is expired |
| 500 | `INTERNAL_ERROR` | Profile retrieval failed | Server error during profile fetch |

### PUT `/api/v1/user/profile/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `UNAUTHORIZED` | Could not validate credentials | Invalid or missing authorization token |
| 422 | - | Validation Error | Invalid profile update data |
| 500 | `INTERNAL_ERROR` | Failed to update profile | Server error during profile update |

## Stories Endpoints

### POST `/api/v1/stories/generate/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `UNAUTHORIZED` | Could not validate credentials | Invalid or missing authorization token |
| 422 | - | Validation Error | Invalid story generation parameters |
| 500 | `STORY_GENERATION_FAILED` | Story generation failed | Failed to generate or save story |

**Example Error Response:**
```json
{
  "success": false,
  "message": "Story generation failed",
  "errors": ["Failed to generate or save story"],
  "error_code": "STORY_GENERATION_FAILED"
}
```

### GET `/api/v1/stories/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `UNAUTHORIZED` | Could not validate credentials | Invalid or missing authorization token |
| 422 | - | Validation Error | Invalid pagination parameters (skip, limit) |
| 500 | `INTERNAL_ERROR` | Stories retrieval failed | Server error during stories fetch |

### GET `/api/v1/stories/{story_id}/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `UNAUTHORIZED` | Could not validate credentials | Invalid or missing authorization token |
| 404 | `STORY_NOT_FOUND` | Story not found | Story doesn't exist or access denied |
| 422 | - | Validation Error | Invalid story ID format |
| 500 | `INTERNAL_ERROR` | Story retrieval failed | Server error during story fetch |

### DELETE `/api/v1/stories/{story_id}/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `UNAUTHORIZED` | Could not validate credentials | Invalid or missing authorization token |
| 404 | `STORY_NOT_FOUND` | Story not found | Story doesn't exist or access denied |
| 422 | - | Validation Error | Invalid story ID format |
| 500 | `INTERNAL_ERROR` | Story deletion failed | Server error during story deletion |

### POST `/api/v1/stories/generate-stream/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 401 | `UNAUTHORIZED` | Could not validate credentials | Invalid or missing authorization token |
| 422 | - | Validation Error | Invalid story generation parameters |
| 500 | `STORY_GENERATION_FAILED` | Story generation failed | Error during streaming generation |

**Stream Error Format:**
```json
{
  "type": "error",
  "message": "Generation failed: <error details>"
}
```

## Admin Endpoints

### GET `/api/v1/admin/users/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 422 | - | Validation Error | Invalid pagination parameters |
| 500 | `INTERNAL_ERROR` | Internal server error | Failed to retrieve users |

### GET `/api/v1/admin/stories/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 422 | - | Validation Error | Invalid pagination parameters |
| 500 | `INTERNAL_ERROR` | Internal server error | Failed to retrieve stories |

## Legal Endpoints

### GET `/api/v1/legal/policy-ios/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 500 | `INTERNAL_ERROR` | Policy retrieval failed | Server error during policy fetch |

### GET `/api/v1/legal/terms/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 500 | `INTERNAL_ERROR` | Terms retrieval failed | Server error during terms fetch |

## Health Check Endpoints

### GET `/api/v1/health/app/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 500 | `SERVICE_UNAVAILABLE` | Application unhealthy | Application is not responding properly |

### GET `/api/v1/health/openai/quick/`

**Possible Errors:**

| Status Code | Error Code | Message | Description |
|-------------|------------|---------|-------------|
| 503 | - | OpenAI API is not responsive | OpenAI service is unavailable |
| 503 | - | Quick OpenAI check failed | Error during OpenAI connectivity check |

## Error Codes Reference

| Error Code | Category | Description |
|------------|----------|-------------|
| `USER_EXISTS` | Authentication | Email is already registered |
| `USER_NOT_FOUND` | Authentication | User account doesn't exist |
| `INVALID_PASSWORD` | Authentication | Incorrect password |
| `TOKEN_EXPIRED` | Authentication | JWT token is expired |
| `INVALID_APPLE_CREDENTIALS` | Authentication | Apple Sign In credentials invalid |
| `VALIDATION_ERROR` | Validation | Request data validation failed |
| `UNAUTHORIZED` | Authorization | Authentication required or invalid |
| `FORBIDDEN` | Authorization | Access denied |
| `INTERNAL_ERROR` | Server | Internal server error |
| `SERVICE_UNAVAILABLE` | Server | Service temporarily unavailable |
| `RESOURCE_NOT_FOUND` | Resource | Requested resource not found |
| `RESOURCE_CONFLICT` | Resource | Resource conflict |
| `STORY_NOT_FOUND` | Story | Story doesn't exist or access denied |
| `STORY_GENERATION_FAILED` | Story | Story generation or saving failed |

## Client Integration Guidelines

### Error Handling Best Practices

1. **Always check the `success` field** in the response
2. **Use `error_code` for programmatic error handling** instead of relying on status codes alone
3. **Display `message` to users** for user-friendly error messages
4. **Log `errors` array** for debugging purposes
5. **Handle authentication errors** by redirecting to login page
6. **Implement retry logic** for `INTERNAL_ERROR` and `SERVICE_UNAVAILABLE` errors

### Example Client Error Handler

```javascript
function handleApiError(response) {
  if (!response.success) {
    switch (response.error_code) {
      case 'USER_NOT_FOUND':
      case 'INVALID_PASSWORD':
        showError('Invalid login credentials');
        break;
      case 'TOKEN_EXPIRED':
      case 'UNAUTHORIZED':
        redirectToLogin();
        break;
      case 'STORY_NOT_FOUND':
        showError('Story not found or access denied');
        break;
      case 'INTERNAL_ERROR':
        showError('Something went wrong. Please try again.');
        break;
      default:
        showError(response.message);
    }
  }
}
```

### Authentication Token Handling

- Include token in **Authorization header**: `Bearer <token>`
- Handle **401 responses** by refreshing token or redirecting to login
- Store tokens securely (use secure cookies or encrypted storage)
- Monitor token expiration and refresh proactively
