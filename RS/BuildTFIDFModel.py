import pandas as pd
import numpy as np
# import firebase_admin
# from firebase_admin import credentials, storage, firestore
from DataClean import tokenize_words
from sklearn.feature_extraction.text import TfidfVectorizer
from utilities import encodeDF, decode2df, divideString, encodeObject, decodeObject

# Only needs to run once when initializing the app
# cred = credentials.Certificate("cs125-healthapp-firebase-adminsdk-5vvud-3b42de41dd.json")
# app = firebase_admin.initialize_app(cred)

# db = firestore.client()

def build_general_tfidf_model():
    # Only needs to run once when initializing the app
    print("Begin to retrieve data...")
    string = ""
    for i in range(1000):
        string += db.collection("CleanRecipeDataBase").document(f"CleanData Part {i}").get().to_dict()["Data"]
    df = decode2df(string)
    print("Finish retrieving")

    print("Begin to train general TF-IDF model...")
    df['RecipeIngredientParts'] = df.RecipeIngredientParts.values.astype('U')
    tfidf = TfidfVectorizer()
    tfidf.fit(df['RecipeIngredientParts'])
    print("Finish training")

    print("Begin to tokenize original receipts...")
    tfidf_recipe = tfidf.transform(df['RecipeIngredientParts'])
    print("Finish tokenizing")

    print("Begin to save model...")
    model_string = encodeObject(tfidf)
#    db.collection("TFIDF_General").document(f"TFIDF_Model").set({"Data": model_string})
    print("Finish saving")

    print("Begin to save tokenized receipts...")
    matrix_string = encodeObject(tfidf_recipe)
    parts = divideString(matrix_string, 1000)
    index = 0
    for i in parts:
#        db.collection("TFIDF_General").document(f"TFIDF_Recipe Part {index}").set({"Data": parts[i]})
        index += 1
    print("Finish saving")


def build_customize_tfidf_model(db, user_name, allegeries):
    print("Begin to retrieve data...")
    string = ""
    model = db.collection("TFIDF_General").document(f"TFIDF_Model").get().to_dict()["Data"]
    tfidf_model = decodeObject(model)
    string = ""
    for i in range(1000):
        string += db.collection("CleanRecipeDataBase").document(f"CleanData Part {i}").get().to_dict()["Data"]
    df = decode2df(string)
    string = ""
    for i in range(1000):
        string += db.collection("TFIDF_General").document(f"TFIDF_Recipe Part {i}").get().to_dict()["Data"]
    tfidf_recipe = decodeObject(string)
    print("Finish retrieving")

    tokenize_allegeries = tokenize_words(allegeries).split(' ')
    indices = [tfidf_model.vocabulary_.get(token) for token in tokenize_allegeries if tfidf_model.vocabulary_.get(token) is not None]

    valid_recipe_mask = np.ones((tfidf_recipe.shape[0],), dtype=bool)
    for idx in indices:
        if idx is not None:
            valid_recipe_mask &= (tfidf_recipe[:, idx].toarray().ravel() == 0)

    df = df[valid_recipe_mask]

    categories = [
    "Snacks Sweet",
    "Peanut Butter",
    "Nuts",
    "Sourdough Breads",
    "Cheesecake",
    "Chocolate Chip Cookies",
    "Ice Cream",
    "Peanut Butter Pie",
    "Pumpkin",
    "Desserts Fruit",
    "Gelatin",
    "Pineapple",
    "Lemon Cake",
    "Margarita",
    "Bread Pudding",
    "Tarts",
    "Frozen Desserts",
    "Coconut Cream Pie",
    "Smoothies",
    "Jellies",
    "Sauces",
    "Spreads",
    "Punch Beverage",
    "Beverages",
    ]

    df_meal = df[~df['RecipeCategory'].apply(lambda x: x in categories)]
    df_snack = df[df['RecipeCategory'].apply(lambda x: x in categories)]
    df_meal['RepeatChoose'] = 0
    df_meal['RepeatIgnore'] = 0
    df_snack['RepeatChoose'] = 0
    df_snack['RepeatIgnore'] = 0

    meal_string = encodeDF(df_meal)
    meal_parts = divideString(meal_string, 1000)
    index = 0
    for i in meal_parts:
        db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {index}").set({"Data": meal_parts[i]})

    snack_string = encodeDF(df_snack)
    snack_parts = divideString(snack_string, 1000)
    index = 0
    for i in snack_parts:
        db.collection("users").document(user_name).collection("CleanSnackRecipes").document(f"CleanData Part {index}").set({"Data": snack_parts[i]})

    print("Begin to train customize TF-IDF model...")
    df_meal['RecipeIngredientParts'] = df_meal.RecipeIngredientParts.values.astype('U')
    tfidf = TfidfVectorizer()
    tfidf.fit(df_meal['RecipeIngredientParts'])
    print("Finish training")

    print("Begin to tokenize original receipts...")
    tfidf_recipe = tfidf.transform(df_meal['RecipeIngredientParts'])
    print("Finish tokenizing")

    print("Begin to save model...")
    model_string = encodeObject(tfidf)
    db.collection("users").document(user_name).collection("TFIDF_Customize_Meal").document(f"TFIDF_Meal_Model").set({"Data": model_string})
    print("Finish saving")

    print("Begin to save tokenized receipts...")
    matrix_string = encodeObject(tfidf_recipe)
    parts = divideString(matrix_string, 1000)
    index = 0
    for i in parts:
        db.collection("users").document(user_name).collection("TFIDF_Customize_Meal").document(f"TFIDF_Meal_Recipe Part {index}").set({"Data": parts[i]})
        index += 1
    print("Finish saving")

    print("Begin to train customize TF-IDF model...")
    df_snack['RecipeIngredientParts'] = df_snack.RecipeIngredientParts.values.astype('U')
    tfidf = TfidfVectorizer()
    tfidf.fit(df_snack['RecipeIngredientParts'])
    print("Finish training")

    print("Begin to tokenize original receipts...")
    tfidf_recipe = tfidf.transform(df_snack['RecipeIngredientParts'])
    print("Finish tokenizing")

    print("Begin to save model...")
    model_string = encodeObject(tfidf)
    db.collection("users").document(user_name).collection("TFIDF_Customize_Snack").document(f"TFIDF_Snack_Model").set({"Data": model_string})
    print("Finish saving")

    print("Begin to save tokenized receipts...")
    matrix_string = encodeObject(tfidf_recipe)
    parts = divideString(matrix_string, 1000)
    index = 0
    for i in parts:
        db.collection("users").document(user_name).collection("TFIDF_Customize_Snack").document(f"TFIDF_Snack_Recipe Part {index}").set({"Data": parts[i]})
        index += 1
    print("Finish saving")


# def update_customize_tfidf_model(allegeries):
#     tfidf_model = load('TFIDF_Customize_model.joblib')
#     tfidf_recipe = load('TFIDF_Customize_recipe.joblib')
#     df = pd.read_pickle("cleaned_data_with_allegery.pkl")

#     tokenize_allegeries = tokenize_words(allegeries).split(' ')
#     indices = [tfidf_model.vocabulary_.get(token) for token in tokenize_allegeries if tfidf_model.vocabulary_.get(token) is not None]

#     valid_recipe_mask = np.ones((tfidf_recipe.shape[0],), dtype=bool)
#     for idx in indices:
#         if idx is not None:
#             valid_recipe_mask &= (tfidf_recipe[:, idx].toarray().ravel() == 0)

#     df = df[valid_recipe_mask]
#     df.to_pickle("cleaned_data_with_allegery.pkl")

#     print("Begin to train customize TF-IDF model...")
#     df['RecipeIngredientParts'] = df.RecipeIngredientParts.values.astype('U')
#     tfidf = TfidfVectorizer()
#     tfidf.fit(df['RecipeIngredientParts'])
#     print("Finish training")

#     print("Begin to tokenize original receipts...")
#     tfidf_recipe = tfidf.transform(df['RecipeIngredientParts'])
#     print("Finish tokenizing")

#     print("Begin to save model...")
#     model_name = "TFIDF_Customize_model.joblib"
#     dump(tfidf, model_name)
#     print("Finish saving")

#     print("Begin to save tokenized receipts...")
#     matrix_filename = 'TFIDF_Customize_recipe.joblib'
#     dump(tfidf_recipe, matrix_filename)
#     print("Finish saving")



