# Dependencies for callable functions.
from firebase_functions import https_fn, options

# Dependencies for writing to Realtime Database.
from firebase_admin import db, initialize_app

import numpy as np

@https_fn.on_request(
    cors=options.CorsOptions(
        cors_origins=[r"firebase\.com$", r"https://flutter\.com"],
        cors_methods=["get", "post"],
    )
)
def helloWorld(req: https_fn.Request) -> https_fn.Response:
    array = np.array([1, 2, 3])
    return https_fn.Response("Hello world!")
