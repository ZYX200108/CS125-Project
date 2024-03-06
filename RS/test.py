import firebase_admin
from firebase_admin import credentials, storage, firestore

cred = credentials.Certificate("cs125-healthapp-firebase-adminsdk-5vvud-3b42de41dd.json")
app = firebase_admin.initialize_app(cred)

db = firestore.client()

users_ref = db.collection("users")
docs = users_ref.stream()

for doc in docs:
    print(doc.to_dict())
    print(type(doc.to_dict()["target Date"]))

def download_large_file(bucket_name, source_blob_name, destination_file_name):
    bucket = storage.bucket(bucket_name)
    blob = bucket.blob(source_blob_name)

    # Download the file to a local file path
    blob.download_to_filename(destination_file_name)

if __name__ == "__main__":
    bucket_name = 'cs125-healthapp.appspot.com'
    source_blob_name = 'recipe.pkl'
    destination_file_name = 'recipe.pkl'  # Adjust this path as necessary
    download_large_file(bucket_name, source_blob_name, destination_file_name)