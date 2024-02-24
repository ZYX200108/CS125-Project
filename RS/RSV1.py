import numpy as np
import pandas as pd
import re
from joblib import load
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import normalize
from DataClean import tokenize_words

def Read_data(file_path):
    return pd.read_pickle(file_path)

def parse_and_format_steps(recipe_steps_str):
    recipe_steps_str = recipe_steps_str[2:-1]
    initial_steps = re.split('",\s*"\n*|",\n*"', recipe_steps_str)
    all_steps = []

    for step in initial_steps:
        step = step.strip('"')
        sub_steps = re.split(r'\.\s+(?=[A-Z])', step)
        all_steps.extend(sub_steps)
    formatted_steps = "\n".join(f"{i+1}. {step}" for i, step in enumerate(all_steps))
    
    return formatted_steps

def recommend_top_5_receipts(file_path, ingredients, currentNutributionDict, value=1):
    general_customize = {0: 'General', 1: 'CustomizeMeal', 2: 'CustomizeSnack'}
    tfidf_model = load('TFIDF_{}_model.joblib'.format(general_customize[value]))
    tfidf_recipe = normalize(load('tfidf_{}_recipe.joblib'.format(general_customize[value])))
    enocde_ingredients = normalize(tfidf_model.transform([tokenize_words(ingredients)]))
    Recommendations = np.array(list(cosine_similarity(enocde_ingredients, tfidf_recipe)[0]))
    Top_30 = Recommendations.argsort()[-30:][::-1]
    df = Read_data(file_path)
    df['Calories'] = pd.to_numeric(df['Calories'], errors='coerce')
    df['FatContent'] = pd.to_numeric(df['FatContent'], errors='coerce')
    df['CholesterolContent'] = pd.to_numeric(df['CholesterolContent'], errors='coerce')
    df['SodiumContent'] = pd.to_numeric(df['SodiumContent'], errors='coerce')
    df['CarbohydrateContent'] = pd.to_numeric(df['CarbohydrateContent'], errors='coerce')
    df['FiberContent'] = pd.to_numeric(df['FiberContent'], errors='coerce')
    df['ProteinContent'] = pd.to_numeric(df['ProteinContent'], errors='coerce')
    df['SugarContent'] = pd.to_numeric(df['SugarContent'], errors='coerce')
    receipts = df.iloc[Top_30]
    receipts = receipts[
        (receipts["Calories"] <= currentNutributionDict['daliyCal']) &
        (receipts["FatContent"] <= currentNutributionDict['fat']) &
        (receipts["CholesterolContent"] <= currentNutributionDict['cholesterol']) &
        (receipts["SodiumContent"] <= currentNutributionDict['sodium']) &
        (receipts["CarbohydrateContent"] <= currentNutributionDict['carbs']) &
        (receipts["FiberContent"] <= currentNutributionDict['fiber']) &
        (receipts["ProteinContent"] <= currentNutributionDict['protein']) &
        (receipts["SugarContent"] <= currentNutributionDict['sugar'])
    ]   
    return receipts[:5]

def get_receipts(file_path, ingredients, currentNutributionDict, value=1): # value=1 means consider allergies, value=0 means not consider allergies
    receipts = recommend_top_5_receipts(file_path, ingredients, currentNutributionDict, value)
    receipts_info = []
    for i in range(5):
        recei = {}
        recei['Name'] = receipts.iloc[i]['Name']
        items = receipts.iloc[i]['RecipeIngredientQuantities'][3:-1].split('", "')
        words_q = [word for item in items for word in item.strip('"').split(' ')]
        items = receipts.iloc[i]['RecipeIngredientParts'][3:-1].split('", "')
        words_p = [word for item in items for word in item.strip('"').split(' ')]
        combined_list = [f"{q} {i}" for q, i in zip(words_q, words_p)]
        recei['Ingredients'] = ', '.join(combined_list)
        numbered_steps = parse_and_format_steps(receipts.iloc[i]['RecipeInstructions'])
        recei['Steps'] = numbered_steps
        recei['Calories'] = receipts.iloc[i]['Calories']
        recei['Fat'] = receipts.iloc[i]['FatContent']
        recei['Cholesterol'] = receipts.iloc[i]['CholesterolContent']
        recei['Sodium'] = receipts.iloc[i]['SodiumContent']
        recei['Carbohydrate'] = receipts.iloc[i]['CarbohydrateContent']
        recei['Fiber'] = receipts.iloc[i]['FiberContent']
        recei['Protein'] = receipts.iloc[i]['ProteinContent']
        recei['Sugar'] = receipts.iloc[i]['SugarContent']
        receipts_info.append(recei)
    return receipts_info
