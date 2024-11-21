from flask import Flask, request, jsonify
app = Flask(__name__)

if __name__ == '__main__':
    app.run()

@app.route('/index')
def index():
    return 'Hello World'

@app.route('/parse', methods=['POST'])
def parse_request():
    data = request.get_json()
    question = data.get('question', '')
    
    # Ollama API endpoint
    response = requests.post('http://localhost:11434/api/generate', 
        json={'model': 'llama3.2', 'prompt': question})
    
    result = response.json()
    return jsonify({'response': parse(result['response'])})


## FUNCTIONS
# Parse function (placeholder for now)
def parse(text):
    return text