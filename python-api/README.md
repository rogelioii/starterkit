# Python String API

A simple Flask API that accepts a string and returns it with a random integer.

## Features

- Accepts strings via GET query parameters or POST JSON body
- Returns the original string with a random integer (1-1000)
- Includes health check endpoint
- Supports both GET and POST methods

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Testing

The project includes a comprehensive test suite using pytest. The tests cover both GET and POST endpoints, error handling, edge cases, and additional endpoints.

### Running Tests

1. **Run all tests:**
```bash
pytest
```

2. **Run with verbose output:**
```bash
pytest -v
```

3. **Run specific test class:**
```bash
pytest test_app.py::TestStringAPI
```

4. **Run specific test method:**
```bash
pytest test_app.py::TestStringAPI::test_get_string_success
```

5. **Run with coverage report:**
```bash
pip install pytest-cov
pytest --cov=app --cov-report=html
```

### Test Coverage

The test suite includes:

- ✅ **GET endpoint tests** - Success cases and error handling
- ✅ **POST endpoint tests** - JSON and form data support
- ✅ **Error handling** - Missing parameters, empty bodies
- ✅ **Edge cases** - Special characters, unicode, empty strings
- ✅ **Random integer validation** - Range checking and randomness
- ✅ **Additional endpoints** - Health check and root endpoint
- ✅ **HTTP method validation** - Invalid method handling

### Test Examples

```bash
# Test successful GET request
pytest test_app.py::TestStringAPI::test_get_string_success -v

# Test POST with JSON
pytest test_app.py::TestStringAPI::test_post_string_success_json -v

# Test error handling
pytest test_app.py::TestStringAPI::test_get_string_missing_parameter -v

# Test edge cases
pytest test_app.py::TestStringAPI::test_string_with_unicode -v
```

## Docker Deployment

The application can be packaged and deployed using Docker. A complete build and push script is provided.

### Prerequisites

1. **Docker installed and running**
2. **Docker Hub account** (create at https://hub.docker.com)
3. **Logged into Docker Hub**: `docker login`

### Building and Pushing to Docker Hub

1. **Make the script executable:**
```bash
chmod +x build-and-push.sh
```

2. **Build and push the image:**
```bash
./build-and-push.sh
```

This will:
- Build the Docker image (`rogelioii/starterkit:latest`)
- Test the container locally
- Push to Docker Hub

### Script Options

```bash
# Build, test, and push (default)
./build-and-push.sh

# Only build, don't push
./build-and-push.sh --build-only

# Only push existing image
./build-and-push.sh --push-only

# Skip testing
./build-and-push.sh --no-test

# Show help
./build-and-push.sh --help
```

### Running the Docker Image

```bash
# Run locally
docker run -p 5000:5555 rogelioii/starterkit:latest

# Run in background
docker run -d -p 5000:5555 --name starterkit-api rogelioii/starterkit:latest

# Stop the container
docker stop starterkit-api
docker rm starterkit-api
```

### Docker Image Features

- ✅ **Multi-stage build** for optimized image size
- ✅ **Non-root user** for security
- ✅ **Health check** endpoint monitoring
- ✅ **Python 3.11** slim base image
- ✅ **Production-ready** configuration

## Usage

### Running the Application

```bash
python app.py
```

The API will be available at `http://localhost:5555`

### API Endpoints

#### GET Request
```bash
curl "http://localhost:5555/api/string?text=hello"
```

#### POST Request
```bash
curl -X POST http://localhost:5555/api/string \
  -H "Content-Type: application/json" \
  -d '{"text": "hello"}'
```

#### Health Check
```bash
curl http://localhost:5555/health
```

### Response Format

```json
{
  "original_text": "hello",
  "random_integer": 42,
  "result": "hello 42"
}
```

### Error Response

```json
{
  "error": "No text provided",
  "message": "Please provide text via query parameter (GET) or JSON body (POST)"
}
```

## API Documentation

- **GET /api/string?text=\<your_string>** - Process string via query parameter
- **POST /api/string** - Process string via JSON body `{"text": "<your_string>"}`
- **GET /health** - Health check endpoint
- **GET /** - API information and available endpoints
