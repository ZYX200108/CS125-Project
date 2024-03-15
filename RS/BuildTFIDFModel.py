import pandas as pd
import numpy as np
from joblib import dump
from joblib import load
from DataClean import tokenize_words
from sklearn.feature_extraction.text import TfidfVectorizer

def build_general_tfidf_model():
    print("Begin to read database...")
    df = pd.read_pickle("cleaned_data.pkl")
    print("Finish Reading")

    print("Begin to train general TF-IDF model...")
    df['RecipeIngredientParts'] = df.RecipeIngredientParts.values.astype('U')
    tfidf = TfidfVectorizer()
    tfidf.fit(df['RecipeIngredientParts'])
    print("Finish training")

    print("Begin to tokenize original receipts...")
    tfidf_recipe = tfidf.transform(df['RecipeIngredientParts'])
    print("Finish tokenizing")

    print("Begin to save model...")
    model_name = "TFIDF_General_model.joblib"
    dump(tfidf, model_name)
    print("Finish saving")

    print("Begin to save tokenized receipts...")
    matrix_filename = 'TFIDF_General_recipe.joblib'
    dump(tfidf_recipe, matrix_filename)
    print("Finish saving")

def update_customize_tfidf_model(allegeries):
    tfidf_model = load('TFIDF_Customize_model.joblib')
    tfidf_recipe = load('TFIDF_Customize_recipe.joblib')
    df = pd.read_pickle("cleaned_data_with_allegery.pkl")

    tokenize_allegeries = tokenize_words(allegeries).split(' ')
    indices = [tfidf_model.vocabulary_.get(token) for token in tokenize_allegeries if tfidf_model.vocabulary_.get(token) is not None]

    valid_recipe_mask = np.ones((tfidf_recipe.shape[0],), dtype=bool)
    for idx in indices:
        if idx is not None:
            valid_recipe_mask &= (tfidf_recipe[:, idx].toarray().ravel() == 0)

    df = df[valid_recipe_mask]
    df.to_pickle("cleaned_data_with_allegery.pkl")

    print("Begin to train customize TF-IDF model...")
    df['RecipeIngredientParts'] = df.RecipeIngredientParts.values.astype('U')
    tfidf = TfidfVectorizer()
    tfidf.fit(df['RecipeIngredientParts'])
    print("Finish training")

    print("Begin to tokenize original receipts...")
    tfidf_recipe = tfidf.transform(df['RecipeIngredientParts'])
    print("Finish tokenizing")

    print("Begin to save model...")
    model_name = "TFIDF_Customize_model.joblib"
    dump(tfidf, model_name)
    print("Finish saving")

    print("Begin to save tokenized receipts...")
    matrix_filename = 'TFIDF_Customize_recipe.joblib'
    dump(tfidf_recipe, matrix_filename)
    print("Finish saving")




