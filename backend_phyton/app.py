from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, auth, firestore

from api.auth import auth_blueprint
from api.users import users_blueprint
from api.location import location_blueprint
from api.invites import invites_blueprint
from api.friends import friends_blueprint

# Initialize Flask app
app = Flask(__name__)
CORS(app)


# Use your downloaded Firebase config file
cred = credentials.Certificate('path/to/firebase-adminsdk.json')
firebase_admin.initialize_app(cred)

app.register_blueprint(auth_blueprint)
app.register_blueprint(users_blueprint)
app.register_blueprint(location_blueprint)
app.register_blueprint(invites_blueprint)
app.register_blueprint(invites_blueprint)
app.register_blueprint(friends_blueprint)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)