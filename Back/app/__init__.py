from flask import Flask
from .routes import api


def create_app():
    app = Flask(__name__)

    # 블루프린트 등록
    app.register_blueprint(api)

    return app