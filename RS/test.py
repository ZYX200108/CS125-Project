import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("cs125-healthapp-firebase-adminsdk-5vvud-3b42de41dd.json")
app = firebase_admin.initialize_app(cred)

db = firestore.client()

users_ref = db.collection("users")
docs = users_ref.stream()

for doc in docs:
    print(doc.to_dict())
    print(type(doc.to_dict()["target Date"]))

