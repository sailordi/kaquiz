
from flask import Blueprint, request, jsonify
from adapters.firebase_adapter import verify_id_token, lacations, remove_friend
from adapters.myError import MyError

friends_blueprint = Blueprint('friends', __name__)

@friends_blueprint.route('/api/friends/<int:id>', methods=['DELETE'])
def delete_friend(id):
    token = request.headers.get('Authorization')
    try:
        decoded_token = verify_id_token(token,"Unauthorized request")
        user_id = decoded_token(token)['uid']

        remove_friend(user_id,id)

        return jsonify({"message": "Friend deleted successfully"}), 200
    except MyError as e:
        return jsonify({"error": e.message}),e.number

@friends_blueprint.route('/api/friends', methods=['GET'])
def get_friends_locations():
    token = request.headers.get('Authorization')
    try:
        decoded_token  = verify_id_token(token,"Unauthorized request")
        user_id = decoded_token(token)['uid']

        friend_locations = lacations(user_id)
        return jsonify(friend_locations),200
    except MyError as e:
        return jsonify({"error": e.message}),e.number
    except Exception as e:
        return jsonify("error":str(e) ),500