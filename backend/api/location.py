from flask import Blueprint, request, jsonify
from adapter.firebase_adapter import verify_id_token, update_location
from adapters.myError import MyError

location_blueprint = Blueprint('location', __name__)

@location_blueprint.route('/api/locations', methods=['POST'])
def submit_location():
    token = request.headers.get('authorization')
    latitude = request.json['latitude']
    longitude = request.json['longitude']
    user_id = ""

    # Verify token and get user ID from it
    try:
        decoded_token = verify_id_token(token,"Unauthorized request")
        user_id = decoded_token['uid']
    except MyError as e:
        return jsonify({"error": e.message}),e.number

    update_location(user_id,latitude,longitude)

    return jsonify({'message': 'Location updated successfully'}), 200

