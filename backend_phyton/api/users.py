from flask import Blueprint, request, jsonify
from adapters.firebase_adapter import verify_id_token, update_user
from adapters.myError import MyError

users_blueprint = Blueprint('users', __name__)
@users_blueprint.route('/api/users', methods=['PUT'])
def update_user():
    token = request.headers.get('authorization')
    avatar = request.json.get('avatar')
    name = request.json.get('name')
    user_id = ""

    # Verify token and get user ID from it
    try:
        decoded_token = verify_id_token(token,"Unauthorized request")
        user_id = decoded_token['uid']
    except MyError as e:
        return jsonify({"error": e.message}),e.number

    data = update_user(user_id,avatar,name)

    return jsonify({'id': user_id, 'name': name, 'avatar': avatar,'email':data['email']}), 200