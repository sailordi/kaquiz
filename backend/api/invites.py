from flask import Blueprint, request, jsonify
from adapters.firebase_adapter import verify_id_token, send_invite, respond_invite, invites, accept_invite
from adapters.myError import MyError

invites_blueprint = Blueprint('invites', __name__)

@invites_blueprint.route('/api/invites/<int:user_id>', methods=['POST'])
def send_invite(user_id):
    token = request.headers.get('authorization')
    sender_id = ""

    # Verify token and get user ID from it
    try:
        decoded_token = verify_id_token(token,"Unauthorized request")
        sender_id = decoded_token['uid']
    except MyError as e:
        return jsonify({"error": e.message}),e.number

    send_invite(sender_id,user_id)

    return jsonify({'message': 'Invitation sent successfully'}), 200

@invites_blueprint.route('/api/invites/<int:user_id>', methods=['GET'])
def get_invites(user_id):
    token = request.headers.get('authorization')

    # Verify token and get user ID from it
    try:
        decoded_token = verify_id_token(token,"Unauthorized request")
        incoming,outgoing = invites(user_id)
        return jsonify({"incoming": incoming, "outgoing": outgoing}), 200
    except MyError as e:
        return jsonify({"error": e.message}),e.number

@invites_blueprint.route('/api/invites/<int:user_id>/accept', methods=['POST'])
def accept_invite(user_id):
    token = request.headers.get('authorization')

    try:
        # Verify token and get user ID from it
        decoded_token = verify_id_token(token,"Unauthorized request")
        recipient_id = decoded_token['uid']
        #Accept invite logic
        respond_invite(recipient_id,user_id,'accepted')
        add_friend(user_id,recipient_id)
    except MyError as e:
        return jsonify({"error": e.message}),e.number

    return jsonify({'message': 'Invitation accepted successfully'}), 200

@invites_blueprint.route('/api/invites/<int:user_id>/decline', methods=['POST'])
def decline_invite(user_id):
    token = request.headers.get('authorization')

    try:
        # Verify token and get user ID from it
        decoded_token = verify_id_token(token,"Unauthorized request")
        recipient_id = decoded_token['uid']
        #Decline invite logic
        respond_invite(recipient_id,user_id,'declined')
    except MyError as e:
        return jsonify({"error": e.message}),e.number

    return jsonify({'message': 'Invitation declined successfully'}), 200