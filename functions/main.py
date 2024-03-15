# Dependencies for callable functions.
from firebase_functions import https_fn, options, scheduler_fn
import firebase_admin
# Dependencies for writing to Realtime Database.
from firebase_admin import credentials, storage, firestore

import nltk
import unidecode
import base64
import numpy as np
import pandas as pd
import pickle
import re
import requests
import random
from io import BytesIO
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import normalize
from datetime import datetime

nltk.download('wordnet')
cred = credentials.Certificate("cs125-healthapp-firebase-adminsdk-5vvud-16c28be37c.json")
app = firebase_admin.initialize_app(cred)
db = firestore.client()

APP_ID = '324f2faf'
APP_KEY = 'c4d9cf195f9b6021136d65f8ad94f73f'
url = "https://api.edamam.com/api/recipes/v2"

# Utilities Model ##################################################################################################################
def tokenize_words(words):
    # Stemming and Lemmatization
    words_to_remove = ['salt', 'sugar', 'pepper', 'fresh']
    stemmer = nltk.stem.porter.PorterStemmer()
    lemmatizer = nltk.stem.WordNetLemmatizer()
    clean_text = []
    words = [unidecode.unidecode(word.lower()) for word in words if word.isalpha()]
    words = [lemmatizer.lemmatize(stemmer.stem(word)) for word in words]
    words = [word for word in words if word not in words_to_remove]
    clean_text = ' '.join(words)
    return clean_text

def encodeDF(df: pd.DataFrame) -> str:
    pickle_string = pickle.dumps(df)
    encoded_data = base64.b64encode(pickle_string)
    base64_string = encoded_data.decode('utf-8')
    return base64_string

def decode2df(base64_string: str) -> pd.DataFrame:
    encoded_data = base64_string.encode('utf-8')
    pickle_string = base64.b64decode(encoded_data)
    df = pd.read_pickle(BytesIO(pickle_string))
    return df

def are_dataframes_equal(df1: pd.DataFrame, df2: pd.DataFrame, check_index: bool = True) -> bool:
    if df1.shape != df2.shape:
        return False
    if not (df1.columns == df2.columns).all():
        return False
    if not (df1.dtypes == df2.dtypes).all():
        return False
    if not df1.equals(df2):
        return False
    if check_index and not (df1.index.equals(df2.index)):
        return False
    return True

def divideString(s, n):
    part_length = len(s) // n
    remainder = len(s) % n
    parts = {}
    for i in range(n):
        start_index = i * part_length + min(i, remainder)
        end_index = start_index + part_length + (1 if i < remainder else 0)
        parts[f'Recipes Part {i}'] = s[start_index:end_index]
    return parts

def recoverRecipeString(parts):
    string = ""
    for part in parts:
        string += parts[part]
    return string

def encodeObject(obj) -> str:
    pickle_string = pickle.dumps(obj)
    encoded_data = base64.b64encode(pickle_string)
    base64_string = encoded_data.decode('utf-8')
    return base64_string

def decodeObject(base64_string: str):
    encoded_data = base64_string.encode('utf-8')
    pickle_string = base64.b64decode(encoded_data)
    obj = pickle.loads(pickle_string)
    return obj

def divideurlstring(s):
    s = s[2: -1]
    parts = s.split('", "')
    parts[0] = parts[0][1:]
    parts[-1] = parts[-1][:-1]
    return parts

# Calculate Nutritution ############################################################################################################
def calculate_max_daily_calories(height_cm, current_weight_lbs, target_weight_lbs, sex, age, days, activity_level='not knonwn'):
    current_weight_kg = current_weight_lbs / 2.20462
    target_weight_kg = target_weight_lbs / 2.20462

    if sex.lower() == 'male':
        BMR = 88.362 + (13.397 * current_weight_kg) + (4.799 * height_cm) - (5.677 * age)
    else:
        BMR = 447.593 + (9.247 * current_weight_kg) + (3.098 * height_cm) - (4.330 * age)

    if activity_level == 'sedentary':
        adjusted_BMR = BMR * 1.3
    elif activity_level == 'lightly active':
        adjusted_BMR = BMR * 1.575
    elif activity_level == 'moderately active':
        adjusted_BMR = BMR * 1.65
    elif activity_level == 'very active':
        adjusted_BMR = BMR * 1.725
    else:
        adjusted_BMR = BMR * 1.2
    
    total_deficit_lbs = current_weight_kg - target_weight_kg 
    total_caloric_deficit = total_deficit_lbs * 3500
    
    daily_caloric_deficit = total_caloric_deficit / days
    max_daily_calories = adjusted_BMR - daily_caloric_deficit
    
    return max_daily_calories

def dailyNutritions(Height, CurrentWeights, TargetWeights, time, sex, age, activity_level='not knonwn'):
    future_date = datetime.strptime(time, "%Y/%m/%d")
    today_date = datetime.now()
    days = (future_date - today_date).days
    daliyCal = calculate_max_daily_calories(Height, CurrentWeights, TargetWeights, sex, age, days, activity_level)
    fat_max = daliyCal * 0.30 / 9
    cholesterol_max = 300
    sodium_max = 2300
    carbs_max = daliyCal * 0.55 / 4
    if sex == 'Female':
        fiber_recommendation = 25
    else:
        fiber_recommendation = 38
    protein = CurrentWeights * 0.8
    sugar_max = daliyCal * 0.10 / 4  # 1 gram of sugar = 4 calories
    
    dailyNutritionLimitationDict = {'daliyCal': round(daliyCal, 2), 'fat': round(fat_max, 2), 'cholesterol': cholesterol_max, 'sodium': sodium_max, 'carbs': round(carbs_max, 2), 'fiber': fiber_recommendation, 'protein': protein, 'sugar': round(sugar_max, 2)}
    return dailyNutritionLimitationDict

# Customize TFModel Functions ######################################################################################################
def build_customize_tfidf_model(user_name, allegeries):
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
    df_meal['RepeatChoose'] = 0
    df_meal['RepeatIgnore'] = 0

    meal_string = encodeDF(df_meal)
    meal_parts = divideString(meal_string, 1000)
    index = 0
    for i in meal_parts:
        db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {index}").set({"Data": meal_parts[i]})
        index += 1

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

# Preference Functions #############################################################################################################
def initialize_preference_vector(user_name, height, current_weight, target_weight, sex, age, preference):
    categories_encoding = db.collection("RecipeCategory").document(f"RecipeCategory").get().to_dict()["Data"]
    sex_encoding = {'Male': 0, 'Female': 1}

    categories_vector = [0] * len(categories_encoding)
    for category in preference:
        if category in categories_encoding:
            categories_vector[categories_encoding[category]] = 1

    sex_vector = [0] * len(sex_encoding)
    sex_vector[sex_encoding[sex]] = 1

    normalized_height = (height - 100) / 100 
    normalized_current_weight = (current_weight - 50) / 100
    normalized_target_weight = (target_weight - 50) / 100

    preference_vector = categories_vector + sex_vector + [normalized_height, normalized_current_weight, normalized_target_weight] + [age]
    db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").set({"Data": preference_vector})

def update_preference_vector(user_name, which):
    dic = db.collection("users").document(user_name).collection("nutritions").document("currentday").get().to_dict()
    receipts_string = db.collection("users").document(user_name).collection("Recommendation").document("Recommendation").get().to_dict()["Data"]
    receipts = decode2df(receipts_string)
    preference_vector = db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").get().to_dict()["Data"]
    category_encoding = db.collection("RecipeCategory").document(f"RecipeCategory").get().to_dict()["Data"]
    string = ""
    for i in range(1000):
        string += db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {i}").get().to_dict()["Data"]
    df = decode2df(string)
    indexs = list(receipts.index)
    indexs_ignore = np.array(indexs[: which] + indexs[which+1:])
    for i in indexs_ignore:
        df.loc[i, 'RepeatIgnore'] += 1
        df.loc[i, 'RepeatChoose'] = 0
    df.loc[indexs[which], 'RepeatChoose'] += 1
    df.loc[indexs[which], 'RepeatIgnore'] = 0
    receipts_categories = list(receipts['RecipeCategory'])
    need = receipts_categories[which]
    categories_ignore = np.array(receipts_categories[: which] + receipts_categories[which+1:])
    for index, i in enumerate(categories_ignore):
        preference_vector[category_encoding[i]] = max(0, preference_vector[category_encoding[i]] - 0.03 * df.loc[indexs_ignore[index], 'RepeatIgnore'])
    preference_vector[category_encoding[need]] = min(1, preference_vector[category_encoding[i]] + 0.03 * df.loc[indexs[which], 'RepeatIgnore'])
    meal_string = encodeDF(df)
    meal_parts = divideString(meal_string, 1000)
    index = 0
    for i in meal_parts:
        db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {index}").set({"Data": meal_parts[i]})
        index += 1
    db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").set({"Data": preference_vector})

    dic['daliyCal'] = round(dic['daliyCal'] - receipts.iloc[which]['Calories'],2)
    dic['fat'] = round(dic['fat'] - receipts.iloc[which]['FatContent'],2)
    dic['cholesterol'] = round(dic['cholesterol'] - receipts.iloc[which]['CholesterolContent'],2)
    dic['sodium'] = round(dic['sodium'] - receipts.iloc[which]['SodiumContent'],2)
    dic['carbs'] = round(dic['carbs'] - receipts.iloc[which]['CarbohydrateContent'],2)
    dic['fiber'] = round(dic['fiber'] - receipts.iloc[which]['FiberContent'],2)
    dic['protein'] = round(dic['protein'] - receipts.iloc[which]['ProteinContent'],2)
    dic['sugar'] = round(dic['sugar'] - receipts.iloc[which]['SugarContent'],2)
    db.collection("users").document(user_name).collection("nutritions").document("currentday").set(dic)

# Update Daily Nutritions ##########################################################################################################
def update_daily_nutritions(user_name):
    # from the frontend, set a timer at 0:00 to reset the currentday nutritions to everyday nutritions
    # The backend function that needs to be called
    dic = db.collection("users").document(user_name).collection("nutritions").document("everyday").get().to_dict()
    dic['dailyCaloryCost'] = 0
    db.collection("users").document(user_name).collection("nutritions").document("currentday").set(dic)
    dailyRecipes = {"Breakfast": "Not prepared", "Lunch": "Not prepared", "Dinner": "Not prepared"}
    db.collection("users").document(user_name).collection("Recommendation").document("DailyRecipes").set(dailyRecipes)

# Ingredients Recommendation #######################################################################################################
def get_ingredients(which_meal, user_name):
    dic = db.collection("users").document(user_name).collection("nutritions").document("everyday").get().to_dict()
    currentCal = db.collection("users").document(user_name).collection("nutritions").document("currentday").get().to_dict()['dailyCaloryCost']
    match which_meal:
        case 0:
            a = 0.25
            params = {
                        'type': 'public',
                        'app_id': APP_ID,
                        'app_key': APP_KEY,
                        'mealType': 'Breakfast',
                        'calories': f"0-{dic['daliyCal'] * a + currentCal}",
                        'nutrients[CHOCDF]': f"0-{dic['carbs'] * a}",
                        'nutrients[FAT]': f"0-{dic['fat'] * a}",
                        'nutrients[FIBTG]': f"0-{dic['fiber'] * a}",
                        'nutrients[PROCNT]': f"0-{dic['protein'] * a}",
                        'nutrients[SUGAR]': f"0-{dic['sugar'] * a}",
                    } 
        case 1:
            a = 0.35
            params = {
                        'type': 'public',
                        'app_id': APP_ID,
                        'app_key': APP_KEY,
                        'mealType': 'Lunch',
                        'calories': f"0-{dic['daliyCal'] * a}",
                        'nutrients[CHOCDF]': f"0-{dic['carbs'] * a + currentCal}",
                        'nutrients[FAT]': f"0-{dic['fat'] * a}",
                        'nutrients[FIBTG]': f"0-{dic['fiber'] * a}",
                        'nutrients[PROCNT]': f"0-{dic['protein'] * a}",
                        'nutrients[SUGAR]': f"0-{dic['sugar'] * a}",
                    } 
        case 2:
            a = 0.4
            params = {
                        'type': 'public',
                        'app_id': APP_ID,
                        'app_key': APP_KEY,
                        'mealType': 'Dinner',
                        'calories': f"0-{dic['daliyCal'] * a}",
                        'nutrients[CHOCDF]': f"0-{dic['carbs'] * a + currentCal}",
                        'nutrients[FAT]': f"0-{dic['fat'] * a}",
                        'nutrients[FIBTG]': f"0-{dic['fiber'] * a}",
                        'nutrients[PROCNT]': f"0-{dic['protein'] * a}",
                        'nutrients[SUGAR]': f"0-{dic['sugar'] * a}",
                    }
    response = requests.get(url, params=params)
    data = response.json()

    if 'hits' in data:
        index = 0
        lis = []
        for hit in data['hits']:
            sub_lis = []
            recipe = hit['recipe']
            ingredients = recipe['ingredients']
            for ingredient in ingredients:
                sub_lis.append(ingredient['food'])
            if index == 30:
                break
            else:
                index += 1
            lis.append(sub_lis)
        print(lis)
        
        condition = True
        allergies = db.collection("users").document(user_name).get().to_dict()['allergies']
        allergies = [allergy.lower() for allergy in allergies]
        lis_copy = lis.copy()
        final = []
        index = 0

        while condition:
            ingredients = random.choice(lis_copy)
            lis_copy.remove(ingredients)
            for allergy in allergies:
                for ingredient in ingredients:
                    if allergy not in ingredient.lower() and ingredient not in final:
                        final.append(ingredient)
            if len(final) > 0 and index >= 3:
                condition = False
            index += 1
        return final
    else:
        print("No recipes found.")


# Recommendation ###################################################################################################################
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

def recommend_top_5_receipts(user_name, ingredients):
    currentNutributionDict = db.collection("users").document(user_name).collection("nutritions").document("everyday").get().to_dict()
    preference_vector = db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").get().to_dict()["Data"]
    category_encoding = db.collection("RecipeCategory").document(f"RecipeCategory").get().to_dict()["Data"]

    model_string = db.collection("users").document(user_name).collection("TFIDF_Customize_Meal").document(f"TFIDF_Meal_Model").get().to_dict()["Data"]
    tfidf_model = decodeObject(model_string)
    string = ""
    for i in range(1000):
        string += db.collection("users").document(user_name).collection("TFIDF_Customize_Meal").document(f"TFIDF_Meal_Recipe Part {i}").get().to_dict()["Data"]
    tfidf_recipe = normalize(decodeObject(string))
    enocde_ingredients = normalize(tfidf_model.transform([tokenize_words(ingredients)]))

    Recommendations = np.array(list(cosine_similarity(enocde_ingredients, tfidf_recipe)[0]))
    Top_30 = Recommendations.argsort()[-30:][::-1]
    Recommendations_Top_30 = Recommendations[Top_30]

    string = ""
    for i in range(1000):
        string += db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {i}").get().to_dict()["Data"]
    df = decode2df(string)
    df['Calories'] = pd.to_numeric(df['Calories'], errors='coerce')
    df['FatContent'] = pd.to_numeric(df['FatContent'], errors='coerce')
    df['CholesterolContent'] = pd.to_numeric(df['CholesterolContent'], errors='coerce')
    df['SodiumContent'] = pd.to_numeric(df['SodiumContent'], errors='coerce')
    df['CarbohydrateContent'] = pd.to_numeric(df['CarbohydrateContent'], errors='coerce')
    df['FiberContent'] = pd.to_numeric(df['FiberContent'], errors='coerce')
    df['ProteinContent'] = pd.to_numeric(df['ProteinContent'], errors='coerce')
    df['SugarContent'] = pd.to_numeric(df['SugarContent'], errors='coerce')
    receipts = df.iloc[Top_30]
    # Combining Preference Vector
    receipts_categories = list(receipts['RecipeCategory'])
    receipts_categories_value = np.array([preference_vector[category_encoding[category]] for category in receipts_categories])
    Recommendations_Top_30 = Recommendations_Top_30 + 0.1 * receipts_categories_value
    temp = {index: score for index, score in zip(Top_30, Recommendations_Top_30)}
    Top_30 = np.array(list(dict(sorted(temp.items(), key=lambda item: item[1], reverse=True)).keys()))
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

    string = encodeDF(receipts[:5])
    db.collection("users").document(user_name).collection("Recommendation").document("Recommendation").set({"Data": string})
    return receipts[:5]

def get_receipts(user_name, ingredients): 
    # The backend function that needs to be called
    receipts = recommend_top_5_receipts(user_name, ingredients)
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
        parts = divideurlstring(receipts.iloc[i]['Images'])
        recei['Image'] = parts
        receipts_info.append(recei)

    db.collection("users").document(user_name).collection("Recommendation").document("Recommendation_string").set({'Data': receipts_info})
    
# Callable Functions ###############################################################################################################
@https_fn.on_request(
        cors=options.CorsOptions(
        cors_origins=[r"firebase\.com$", r"https://flutter\.com"],
        cors_methods=["get", "post"],
    )
)
def initializeUserModels(req: https_fn.Request) -> https_fn.Response:
    print("start initializing")
    args = req.args
    userName = args["userName"]
    allegeries = db.collection("users").document(userName).get().to_dict()['allergies']
    height = db.collection("users").document(userName).get().to_dict()['height']
    current = db.collection("users").document(userName).get().to_dict()['weight']
    target = db.collection("users").document(userName).get().to_dict()['targetWeight']
    sex = db.collection("users").document(userName).get().to_dict()['sex']
    age = db.collection("users").document(userName).get().to_dict()['age']
    preference = db.collection("users").document(userName).get().to_dict()['foodCategories']
    time = db.collection("users").document(userName).get().to_dict()['target Date']
    activity_level = db.collection("users").document(userName).get().to_dict()['activityLevel']
    string = ""
    for i in time:
        string = string + str(i) + "/"
    string = string[:-1]

    dic = dailyNutritions(height, current, target, string, sex, age, activity_level)
    db.collection("users").document(userName).collection("nutritions").document("everyday").set(dic)
    build_customize_tfidf_model(userName, allegeries)
    initialize_preference_vector(userName, height, current, target, sex, age, preference)
    print("finish initializing")
    ingredients = ["chicken", "onion", "garlic", "tomato", "rice"]
    get_receipts(userName, ingredients)
    return https_fn.Response("User successfully created.")

@https_fn.on_request(
        cors=options.CorsOptions(
        cors_origins=[r"firebase\.com$", r"https://flutter\.com"],
        cors_methods=["get", "post"],
    )
)
def updatePreferenceVector(req: https_fn.Request) -> https_fn.Response:
    print("start updating preference vector")
    args = req.args
    userName = args["userName"]
    which = int(args["which"])
    update_preference_vector(userName, which)
    print("finish updating preference vector")
    return https_fn.Response("Preference Vector Updated.")

@https_fn.on_request(
        cors=options.CorsOptions(
        cors_origins=[r"firebase\.com$", r"https://flutter\.com"],
        cors_methods=["get", "post"],
    )
)
def updateDailyNutritions(req: https_fn.Request) -> https_fn.Response:
    print("start updating daily nutritions")
    args = req.args
    userName = args["userName"]
    update_daily_nutritions(userName)
    print("finish updating daily nutritions")
    return https_fn.Response("Daily Nutritions Updated.")

@https_fn.on_request(
        cors=options.CorsOptions(
        cors_origins=[r"firebase\.com$", r"https://flutter\.com"],
        cors_methods=["get", "post"],
    )
) 
def getReceipts(req: https_fn.Request) -> https_fn.Response:
    print("start getting recipes")
    args = req.args
    userName = args["userName"]
    ingredients = args["ingredients"].split(",")
    get_receipts(userName, ingredients)
    print("finish getting recipes")
    return https_fn.Response("Receipts Updated.")

@scheduler_fn.on_schedule(schedule="every day 7:45")
def morningRecipes(event: scheduler_fn.ScheduledEvent) -> None:
    userNames = []
    users_ref = db.collection("users")
    docs = users_ref.stream()

    for doc in docs:
        userNames.append(doc.to_dict()["name"])
    print(userNames)

    for name in userNames:
        # ingredients = ["mango", "kefir", "ounce", "tomato", "rice", "banana", "blue berry", "egg"]
        dic = db.collection("users").document(name).collection("Recommendation").document("DailyRecipes").get().to_dict()
        ingredients = get_ingredients(0, name)
        get_receipts(name, ingredients)
        print(f"finish {name}'s recipe")
        dic['Breakfast'] = db.collection("users").document(name).collection("Recommendation").document("Recommendation_string").get().to_dict()["Data"]
        db.collection("users").document(name).collection("Recommendation").document("DailyRecipes").set(dic)


@scheduler_fn.on_schedule(schedule="every day 11:45")
def noonRecipes(event: scheduler_fn.ScheduledEvent) -> None:
    userNames = []
    users_ref = db.collection("users")
    docs = users_ref.stream()

    for doc in docs:
        userNames.append(doc.to_dict()["name"])
    print(userNames)

    for name in userNames:
        # ingredients = ["chicken", "onion", "garlic", "tomato", "rice"]
        dic = db.collection("users").document(name).collection("Recommendation").document("DailyRecipes").get().to_dict()
        ingredients = get_ingredients(1, name)
        get_receipts(name, ingredients)
        print(f"finish {name}'s recipe")
        dic['Lunch'] = db.collection("users").document(name).collection("Recommendation").document("Recommendation_string").get().to_dict()["Data"]
        db.collection("users").document(name).collection("Recommendation").document("DailyRecipes").set(dic)

@scheduler_fn.on_schedule(schedule="every day 17:45")
def nightRecipes(event: scheduler_fn.ScheduledEvent) -> None:
    userNames = []
    users_ref = db.collection("users")
    docs = users_ref.stream()

    for doc in docs:
        userNames.append(doc.to_dict()["name"])
    print(userNames)

    for name in userNames:
        # ingredients = ["pork", "onion", "pepper", "oil", "beef"]
        dic = db.collection("users").document(name).collection("Recommendation").document("DailyRecipes").get().to_dict()
        ingredients = get_ingredients(2, name)
        get_receipts(name, ingredients)
        print(f"finish {name}'s recipe")
        dic['Dinner'] = db.collection("users").document(name).collection("Recommendation").document("Recommendation_string").get().to_dict()["Data"]
        db.collection("users").document(name).collection("Recommendation").document("DailyRecipes").set(dic)
