from flask import Flask, request, jsonify
from firebase_admin import firestore,auth
from myError import MyError

db = firestore.client()

def verify_id_token(id_token,errText):
    try:
        decoded_token = auth.verify_id_token(id_token)
        return jsonify({"access_token": decoded_token}), 200
    except auth.AuthError:
        raise MyError(errText,400)
    except Exception as e:
        raise MyError(str(e),500)

def update_user(user_id,avatar,name):
    user_ref =db.collection('users').document(user_id)
    user_ref.update({'avatar': avatar, 'name': name})

    return user_ref.get().to_dict()
def update_location(user_id,latitude,longitude):
    user_ref = db.collection('locations').document(user_id)
    user_ref.set({'latitude': latitude, 'longitude': longitude, 'timestamp': firestore.SERVER_TIMESTAMP})

def send_invite(sender_id,user_id) :
    invites_ref = db.collection('invites')
    invites_ref.add({'sender_id': sender_id, 'recipient_id': user_id, 'status': 'sent',firestore.SERVER_TIMESTAMP})

def respond_invite(recipient_id,user_id,status) :
    invites_ref = db.collection('invites').where('recipient_id', '==', recipient_id)
    for invite in invites_ref.get():
        if invite.to_dict()['sender_id'] == user_id:
            invite.reference.update({'status': status})
            return

    raise MyError("Invitation not found",404)

def invites(user_id) :
    incoming = db.collection('invites').where('recipient_id', '==', user_id).get()
    outgoing = db.collection('invites').where('sender_id', '==', user_id).get()

    incoming_invites = [{"id": doc.id, **doc.to_dict()} for doc in incoming]
    outgoing_invites = [{"id": doc.id, **doc.to_dict()} for doc in outgoing]

    return  incoming_invites,outgoing_invites
