from flask import Flask, request, jsonify
app = Flask(__name__)

if __name__ == '__main__':
    app.run()

@app.route('/index')
def index():
    return 'Hello World'
