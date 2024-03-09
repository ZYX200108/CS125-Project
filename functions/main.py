# Dependencies for callable functions.
from firebase_functions import https_fn, options
import firebase_admin
# Dependencies for writing to Realtime Database.
from firebase_admin import credentials, storage, firestore

import numpy as np

cred = credentials.Certificate("cs125-healthapp-firebase-adminsdk-5vvud-16c28be37c.json")
app = firebase_admin.initialize_app(cred)

@https_fn.on_request(
    cors=options.CorsOptions(
        cors_origins=[r"firebase\.com$", r"https://flutter\.com"],
        cors_methods=["get", "post"],
    )
)
def helloWorld(req: https_fn.Request) -> https_fn.Response:
    array = np.array([1, 2, 3])
    bucket = storage.bucket('cs125-healthapp.appspot.com')
    # blob = bucket.blob('recipe.pkl')
    return https_fn.Response("Hello world!")


@https_fn.on_request(
    cors=options.CorsOptions(
        cors_origins=[r"firebase\.com$", r"https://flutter\.com"],
        cors_methods=["get", "post"],
    )
)
def download_large_file(req: https_fn.Request) -> https_fn.Response:
    bucket = storage.bucket('cs125-healthapp.appspot.com')
    blob = bucket.blob('recipe.pkl')

    # Download the file to a local file path
    blob.download_to_filename('recipe.pkl')
    return https_fn.Response("finish downloading!")