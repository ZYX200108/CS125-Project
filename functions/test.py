# import nltk
# import unidecode
# import base64
# import numpy as np
# import pandas as pd
# import pickle
# from io import BytesIO
# from sklearn.feature_extraction.text import TfidfVectorizer
# from datetime import datetime
# from firebase_functions import https_fn, options
# import firebase_admin
# # Dependencies for writing to Realtime Database.
# from firebase_admin import credentials, storage, firestore


# # Utilities Model #################################################################################################################
# def tokenize_words(words):
#     # Stemming and Lemmatization
#     words_to_remove = ['salt', 'sugar', 'pepper', 'fresh']
#     stemmer = nltk.stem.porter.PorterStemmer()
#     lemmatizer = nltk.stem.WordNetLemmatizer()
#     clean_text = []
#     words = [unidecode.unidecode(word.lower()) for word in words if word.isalpha()]
#     words = [lemmatizer.lemmatize(stemmer.stem(word)) for word in words]
#     words = [word for word in words if word not in words_to_remove]
#     clean_text = ' '.join(words)
#     return clean_text

# def encodeDF(df: pd.DataFrame) -> str:
#     pickle_string = pickle.dumps(df)
#     encoded_data = base64.b64encode(pickle_string)
#     base64_string = encoded_data.decode('utf-8')
#     return base64_string

# def decode2df(base64_string: str) -> pd.DataFrame:
#     encoded_data = base64_string.encode('utf-8')
#     pickle_string = base64.b64decode(encoded_data)
#     df = pd.read_pickle(BytesIO(pickle_string))
#     return df

# def are_dataframes_equal(df1: pd.DataFrame, df2: pd.DataFrame, check_index: bool = True) -> bool:
#     if df1.shape != df2.shape:
#         return False
#     if not (df1.columns == df2.columns).all():
#         return False
#     if not (df1.dtypes == df2.dtypes).all():
#         return False
#     if not df1.equals(df2):
#         return False
#     if check_index and not (df1.index.equals(df2.index)):
#         return False
#     return True

# def divideString(s, n):
#     part_length = len(s) // n
#     remainder = len(s) % n
#     parts = {}
#     for i in range(n):
#         start_index = i * part_length + min(i, remainder)
#         end_index = start_index + part_length + (1 if i < remainder else 0)
#         parts[f'Recipes Part {i}'] = s[start_index:end_index]
#     return parts

# def recoverRecipeString(parts):
#     string = ""
#     for part in parts:
#         string += parts[part]
#     return string

# def encodeObject(obj) -> str:
#     pickle_string = pickle.dumps(obj)
#     encoded_data = base64.b64encode(pickle_string)
#     base64_string = encoded_data.decode('utf-8')
#     return base64_string

# def decodeObject(base64_string: str):
#     encoded_data = base64_string.encode('utf-8')
#     pickle_string = base64.b64decode(encoded_data)
#     obj = pickle.loads(pickle_string)
#     return obj

# # Calculate Nutritution ############################################################################################################
# def calculate_max_daily_calories(height_cm, current_weight_lbs, target_weight_lbs, sex, age, days, activity_level='not knonwn'):
#     current_weight_kg = current_weight_lbs / 2.20462
#     target_weight_kg = target_weight_lbs / 2.20462

#     if sex.lower() == 'm':
#         BMR = 88.362 + (13.397 * current_weight_kg) + (4.799 * height_cm) - (5.677 * age)
#     else:
#         BMR = 447.593 + (9.247 * current_weight_kg) + (3.098 * height_cm) - (4.330 * age)

#     if activity_level == 'sedentary':
#         adjusted_BMR = BMR * 1.3
#     elif activity_level == 'lightly active':
#         adjusted_BMR = BMR * 1.575
#     elif activity_level == 'moderately active':
#         adjusted_BMR = BMR * 1.65
#     elif activity_level == 'very active':
#         adjusted_BMR = BMR * 1.725
#     else:
#         adjusted_BMR = BMR * 1.2
    
#     total_deficit_lbs = current_weight_kg - target_weight_kg 
#     total_caloric_deficit = total_deficit_lbs * 3500
    
#     daily_caloric_deficit = total_caloric_deficit / days
#     max_daily_calories = adjusted_BMR - daily_caloric_deficit
    
#     return max_daily_calories

# def dailyNutritions(Height, CurrentWeights, TargetWeights, time, sex, age):
#     future_date = datetime.strptime(time, "%Y/%m/%d")
#     today_date = datetime.now()
#     days = (future_date - today_date).days
#     daliyCal = calculate_max_daily_calories(Height, CurrentWeights, TargetWeights, sex, age, days)
#     fat_max = daliyCal * 0.30 / 9
#     cholesterol_max = 300
#     sodium_max = 2300
#     carbs_max = daliyCal * 0.55 / 4
#     if sex == 'F':
#         fiber_recommendation = 25
#     else:
#         fiber_recommendation = 38
#     protein = CurrentWeights * 0.8
#     sugar_max = daliyCal * 0.10 / 4  # 1 gram of sugar = 4 calories
    
#     dailyNutritionLimitationDict = {'daliyCal': round(daliyCal, 2), 'fat': round(fat_max, 2), 'cholesterol': cholesterol_max, 'sodium': sodium_max, 'carbs': round(carbs_max, 2), 'fiber': fiber_recommendation, 'protein': protein, 'sugar': round(sugar_max, 2)}
#     return dailyNutritionLimitationDict

# # Customize TFModel Functions ######################################################################################################
# def build_customize_tfidf_model(user_name, allegeries):
#     print("Begin to retrieve data...")
#     string = ""
#     model = db.collection("TFIDF_General").document(f"TFIDF_Model").get().to_dict()["Data"]
#     tfidf_model = decodeObject(model)
#     string = ""
#     for i in range(1000):
#         string += db.collection("CleanRecipeDataBase").document(f"CleanData Part {i}").get().to_dict()["Data"]
#     df = decode2df(string)
#     string = ""
#     for i in range(1000):
#         string += db.collection("TFIDF_General").document(f"TFIDF_Recipe Part {i}").get().to_dict()["Data"]
#     tfidf_recipe = decodeObject(string)
#     print("Finish retrieving")

#     tokenize_allegeries = tokenize_words(allegeries).split(' ')
#     indices = [tfidf_model.vocabulary_.get(token) for token in tokenize_allegeries if tfidf_model.vocabulary_.get(token) is not None]

#     valid_recipe_mask = np.ones((tfidf_recipe.shape[0],), dtype=bool)
#     for idx in indices:
#         if idx is not None:
#             valid_recipe_mask &= (tfidf_recipe[:, idx].toarray().ravel() == 0)

#     df = df[valid_recipe_mask]

#     categories = [
#     "Snacks Sweet",
#     "Peanut Butter",
#     "Nuts",
#     "Sourdough Breads",
#     "Cheesecake",
#     "Chocolate Chip Cookies",
#     "Ice Cream",
#     "Peanut Butter Pie",
#     "Pumpkin",
#     "Desserts Fruit",
#     "Gelatin",
#     "Pineapple",
#     "Lemon Cake",
#     "Margarita",
#     "Bread Pudding",
#     "Tarts",
#     "Frozen Desserts",
#     "Coconut Cream Pie",
#     "Smoothies",
#     "Jellies",
#     "Sauces",
#     "Spreads",
#     "Punch Beverage",
#     "Beverages",
#     ]

#     df_meal = df[~df['RecipeCategory'].apply(lambda x: x in categories)]
#     df_snack = df[df['RecipeCategory'].apply(lambda x: x in categories)]
#     df_meal['RepeatChoose'] = 0
#     df_meal['RepeatIgnore'] = 0
#     df_snack['RepeatChoose'] = 0
#     df_snack['RepeatIgnore'] = 0

#     meal_string = encodeDF(df_meal)
#     meal_parts = divideString(meal_string, 1000)
#     index = 0
#     for i in meal_parts:
#         db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {index}").set({"Data": meal_parts[i]})

#     snack_string = encodeDF(df_snack)
#     snack_parts = divideString(snack_string, 1000)
#     index = 0
#     for i in snack_parts:
#         db.collection("users").document(user_name).collection("CleanSnackRecipes").document(f"CleanData Part {index}").set({"Data": snack_parts[i]})

#     print("Begin to train customize TF-IDF model...")
#     df_meal['RecipeIngredientParts'] = df_meal.RecipeIngredientParts.values.astype('U')
#     tfidf = TfidfVectorizer()
#     tfidf.fit(df_meal['RecipeIngredientParts'])
#     print("Finish training")

#     print("Begin to tokenize original receipts...")
#     tfidf_recipe = tfidf.transform(df_meal['RecipeIngredientParts'])
#     print("Finish tokenizing")

#     print("Begin to save model...")
#     model_string = encodeObject(tfidf)
#     db.collection("users").document(user_name).collection("TFIDF_Customize_Meal").document(f"TFIDF_Meal_Model").set({"Data": model_string})
#     print("Finish saving")

#     print("Begin to save tokenized receipts...")
#     matrix_string = encodeObject(tfidf_recipe)
#     parts = divideString(matrix_string, 1000)
#     index = 0
#     for i in parts:
#         db.collection("users").document(user_name).collection("TFIDF_Customize_Meal").document(f"TFIDF_Meal_Recipe Part {index}").set({"Data": parts[i]})
#         index += 1
#     print("Finish saving")

#     print("Begin to train customize TF-IDF model...")
#     df_snack['RecipeIngredientParts'] = df_snack.RecipeIngredientParts.values.astype('U')
#     tfidf = TfidfVectorizer()
#     tfidf.fit(df_snack['RecipeIngredientParts'])
#     print("Finish training")

#     print("Begin to tokenize original receipts...")
#     tfidf_recipe = tfidf.transform(df_snack['RecipeIngredientParts'])
#     print("Finish tokenizing")

#     print("Begin to save model...")
#     model_string = encodeObject(tfidf)
#     db.collection("users").document(user_name).collection("TFIDF_Customize_Snack").document(f"TFIDF_Snack_Model").set({"Data": model_string})
#     print("Finish saving")

#     print("Begin to save tokenized receipts...")
#     matrix_string = encodeObject(tfidf_recipe)
#     parts = divideString(matrix_string, 1000)
#     index = 0
#     for i in parts:
#         db.collection("users").document(user_name).collection("TFIDF_Customize_Snack").document(f"TFIDF_Snack_Recipe Part {index}").set({"Data": parts[i]})
#         index += 1
#     print("Finish saving")

# # Preference Functions #############################################################################################################
# def initialize_preference_vector(user_name, height, current_weight, target_weight, sex, age, preference):
#     categories_encoding = db.collection("RecipeCategory").document(f"RecipeCategory").get().to_dict()["Data"]
#     sex_encoding = {'Male': 0, 'Female': 1}

#     categories_vector = [0] * len(categories_encoding)
#     for category in preference:
#         if category in categories_encoding:
#             categories_vector[categories_encoding[category]] = 1

#     sex_vector = [0] * len(sex_encoding)
#     sex_vector[sex_encoding[sex]] = 1

#     normalized_height = (height - 100) / 100 
#     normalized_current_weight = (current_weight - 50) / 100
#     normalized_target_weight = (target_weight - 50) / 100

#     preference_vector = categories_vector + sex_vector + [normalized_height, normalized_current_weight, normalized_target_weight] + [age]
#     db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").set({"Data": preference_vector})

# def update_preference_vector(db, user_name, receipts, which, meal=True):
#     preference_vector = db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").get().to_dict()["Data"]
#     category_encoding = db.collection("RecipeCategory").document(f"RecipeCategory").get().to_dict()["Data"]
#     if meal:
#         string = ""
#         for i in range(1000):
#             string += db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {i}").get().to_dict()["Data"]
#         df = decode2df(string)
#     else:
#         string = ""
#         for i in range(1000):
#             string += db.collection("users").document(user_name).collection("CleanSnackRecipes").document(f"CleanData Part {i}").get().to_dict()["Data"]
#         df = decode2df(string)
#     indexs = list(receipts.index)
#     indexs_ignore = np.array(indexs[: which] + indexs[which+1:])
#     df.iloc[indexs_ignore, df.columns.get_loc('RepeatIgnore')] += 1
#     df.iloc[indexs_ignore, df.columns.get_loc('RepeatChoose')] = 0
#     df.iloc[which, df.columns.get_loc('RepeatChoose')] += 1
#     df.iloc[which, df.columns.get_loc('RepeatIgnore')] = 0

#     receipts_categories = list(receipts['RecipeCategory'])
#     need = receipts_categories[which]
#     categories_ignore = np.array(receipts_categories[: which] + receipts_categories[which+1:])
#     for index, i in enumerate(categories_ignore):
#         preference_vector[category_encoding[i]] = max(0, preference_vector[category_encoding[i]] - 0.03 * df.iloc[indexs_ignore[index], df.columns.get_loc('RepeatIgnore')])
#     preference_vector[category_encoding[need]] = min(1, preference_vector[category_encoding[i]] + 0.03 * df.iloc[indexs_ignore[which], df.columns.get_loc('RepeatIgnore')])

#     if meal:
#         meal_string = encodeDF(df)
#         meal_parts = divideString(meal_string, 1000)
#         index = 0
#         for i in meal_parts:
#             db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {index}").set({"Data": meal_parts[i]})
#     else:
#         snack_string = encodeDF(df)
#         snack_parts = divideString(snack_string, 1000)
#         index = 0
#         for i in snack_parts:
#             db.collection("users").document(user_name).collection("CleanSnackRecipes").document(f"CleanData Part {index}").set({"Data": snack_parts[i]})

#     db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").set({"Data": preference_vector})

# nltk.download('wordnet')
# cred = credentials.Certificate("cs125-healthapp-firebase-adminsdk-5vvud-16c28be37c.json")
# app = firebase_admin.initialize_app(cred)

# db = firestore.client()

# userName = "Zhe"

# allegeries = db.collection("users").document(userName).get().to_dict()['allergies']
# height = db.collection("users").document(userName).get().to_dict()['height']
# current = db.collection("users").document(userName).get().to_dict()['weight']
# target = db.collection("users").document(userName).get().to_dict()['targetWeight']
# sex = db.collection("users").document(userName).get().to_dict()['sex']
# age = db.collection("users").document(userName).get().to_dict()['age']
# preference = db.collection("users").document(userName).get().to_dict()['foodCategories']
# time = db.collection("users").document(userName).get().to_dict()['target Date']
# string = ""
# for i in time:
#     string = string + str(i) + "/"
# string = string[:-1]

# dic = dailyNutritions(height, current, target, string, sex, age)
# db.collection("users").document(userName).collection("nutritions").document("everyday").set(dic)
# # build_customize_tfidf_model(userName, allegeries)
# initialize_preference_vector(userName, height, current, target, sex, age, preference)

