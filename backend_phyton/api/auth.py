from flask import Blueprint, request, jsonify,
from adapters.firebase_adapter import verify_id_token
from adapters.myError import MyError

auth_blueprint = Blueprint('auth', __name__)

@auth_blueprint.route('/auth', methods=['POST'])
def authenticate_user():
    id_token = request.json.get('id_token')
    try:
        decoded_token = verify_id_token(id_token,"Invalid ID token")
        return jsonify({"access_token": decoded_token}),200
    except MyError as e:
        return jsonify({"error": e.message}),e.number