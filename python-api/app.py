from flask import Flask, request, jsonify
import random

app = Flask(__name__)

@app.route('/api/string', methods=['GET', 'POST'])
def process_string():
    """
    Accepts a string via GET parameter or POST body and returns it with a random integer.
    
    GET: /api/string?text=your_string_here
    POST: /api/string with JSON body {"text": "your_string_here"}
    """
    text = None
    
    if request.method == 'GET':
        # Get text from query parameter
        text = request.args.get('text')
    elif request.method == 'POST':
        # Get text from JSON body
        if request.is_json:
            data = request.get_json()
            text = data.get('text')
        else:
            # Fallback to form data
            text = request.form.get('text')
    
    if text is None:
        return jsonify({
            'error': 'No text provided',
            'message': 'Please provide text via query parameter (GET) or JSON body (POST)'
        }), 400
    
    # Generate random integer between 1 and 1000
    random_int = random.randint(1, 1000)
    
    return jsonify({
        'original_text': text,
        'random_integer': random_int,
        'result': f"{text} {random_int}"
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'message': 'API is running'})

@app.route('/', methods=['GET'])
def root():
    """Root endpoint with API information"""
    return jsonify({
        'message': 'Python String API',
        'version': '1.0.0',
        'endpoints': {
            'GET /api/string?text=<your_string>': 'Process string via query parameter',
            'POST /api/string': 'Process string via JSON body {"text": "<your_string>"}',
            'GET /health': 'Health check',
            'GET /': 'This information'
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5555, debug=True)
