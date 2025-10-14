import pytest
import json
from urllib.parse import quote
from app import app

@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

class TestStringAPI:
    """Test cases for the string API endpoints."""
    
    def test_get_string_success(self, client):
        """Test successful GET request with text parameter."""
        response = client.get('/api/string?text=hello')
        
        assert response.status_code == 200
        data = json.loads(response.data)
        
        assert 'original_text' in data
        assert 'random_integer' in data
        assert 'result' in data
        assert data['original_text'] == 'hello'
        assert isinstance(data['random_integer'], int)
        assert 1 <= data['random_integer'] <= 1000
        assert data['result'] == f"hello {data['random_integer']}"
    
    def test_post_string_success_json(self, client):
        """Test successful POST request with JSON body."""
        payload = {'text': 'world'}
        response = client.post('/api/string', 
                              data=json.dumps(payload),
                              content_type='application/json')
        
        assert response.status_code == 200
        data = json.loads(response.data)
        
        assert 'original_text' in data
        assert 'random_integer' in data
        assert 'result' in data
        assert data['original_text'] == 'world'
        assert isinstance(data['random_integer'], int)
        assert 1 <= data['random_integer'] <= 1000
        assert data['result'] == f"world {data['random_integer']}"
    
    def test_post_string_success_form(self, client):
        """Test successful POST request with form data."""
        payload = {'text': 'form_test'}
        response = client.post('/api/string', data=payload)
        
        assert response.status_code == 200
        data = json.loads(response.data)
        
        assert data['original_text'] == 'form_test'
        assert isinstance(data['random_integer'], int)
        assert 1 <= data['random_integer'] <= 1000
    
    def test_get_string_missing_parameter(self, client):
        """Test GET request without text parameter."""
        response = client.get('/api/string')
        
        assert response.status_code == 400
        data = json.loads(response.data)
        
        assert 'error' in data
        assert 'message' in data
        assert data['error'] == 'No text provided'
    
    def test_post_string_missing_body(self, client):
        """Test POST request without text in body."""
        response = client.post('/api/string')
        
        assert response.status_code == 400
        data = json.loads(response.data)
        
        assert 'error' in data
        assert 'message' in data
        assert data['error'] == 'No text provided'
    
    def test_post_string_empty_json(self, client):
        """Test POST request with empty JSON body."""
        response = client.post('/api/string',
                              data=json.dumps({}),
                              content_type='application/json')
        
        assert response.status_code == 400
        data = json.loads(response.data)
        
        assert 'error' in data
        assert data['error'] == 'No text provided'
    
    def test_post_string_missing_text_key(self, client):
        """Test POST request with JSON body missing 'text' key."""
        payload = {'message': 'hello'}
        response = client.post('/api/string',
                              data=json.dumps(payload),
                              content_type='application/json')
        
        assert response.status_code == 400
        data = json.loads(response.data)
        
        assert 'error' in data
        assert data['error'] == 'No text provided'
    
    def test_string_with_special_characters(self, client):
        """Test API with special characters and spaces."""
        test_string = "Hello, World! 123 @#$%"
        
        # Test GET - URL encode special characters
        encoded_string = quote(test_string)
        response = client.get(f'/api/string?text={encoded_string}')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['original_text'] == test_string
        
        # Test POST
        payload = {'text': test_string}
        response = client.post('/api/string',
                              data=json.dumps(payload),
                              content_type='application/json')
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['original_text'] == test_string
    
    def test_string_with_unicode(self, client):
        """Test API with unicode characters."""
        test_string = "Hello 世界 🌍"
        
        payload = {'text': test_string}
        response = client.post('/api/string',
                              data=json.dumps(payload),
                              content_type='application/json')
        
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['original_text'] == test_string
    
    def test_empty_string(self, client):
        """Test API with empty string."""
        payload = {'text': ''}
        response = client.post('/api/string',
                              data=json.dumps(payload),
                              content_type='application/json')
        
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['original_text'] == ''
        assert data['result'] == f" {data['random_integer']}"
    
    def test_random_integer_range(self, client):
        """Test that random integers are within expected range."""
        # Run multiple requests to test randomness
        integers = []
        for _ in range(10):
            response = client.get('/api/string?text=test')
            assert response.status_code == 200
            data = json.loads(response.data)
            integers.append(data['random_integer'])
        
        # All integers should be between 1 and 1000
        for num in integers:
            assert 1 <= num <= 1000
        
        # Should have some variation (not all the same)
        assert len(set(integers)) > 1, "Random integers should vary"
    
    def test_health_endpoint(self, client):
        """Test the health check endpoint."""
        response = client.get('/health')
        
        assert response.status_code == 200
        data = json.loads(response.data)
        
        assert 'status' in data
        assert 'message' in data
        assert data['status'] == 'healthy'
        assert data['message'] == 'API is running'
    
    def test_root_endpoint(self, client):
        """Test the root endpoint."""
        response = client.get('/')
        
        assert response.status_code == 200
        data = json.loads(response.data)
        
        assert 'message' in data
        assert 'version' in data
        assert 'endpoints' in data
        assert data['message'] == 'Python String API'
        assert data['version'] == '1.0.0'
        assert isinstance(data['endpoints'], dict)
    
    def test_invalid_methods(self, client):
        """Test that invalid HTTP methods return appropriate errors."""
        # Test PUT method (not supported)
        response = client.put('/api/string')
        assert response.status_code == 405  # Method Not Allowed
        
        # Test DELETE method (not supported)
        response = client.delete('/api/string')
        assert response.status_code == 405  # Method Not Allowed
