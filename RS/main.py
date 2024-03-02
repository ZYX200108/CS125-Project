import pickle
import pandas as pd
from datetime import datetime
from RSV1 import get_receipts
from ReadData import read_data
from DataClean import tokenize_words, clean_data
from BuildTFIDFModel import build_customize_tfidf_model, build_general_tfidf_model, update_customize_tfidf_model
from BuildPreferenceModel import initialize_preference_vector
# from firebase_functions import firestore_fn, https_fn
# from firebase_admin import initialize_app, firestore
# import google.cloud.firestore

# app = initialize_app()

def recommend_function(Ingredients, Allegerie, currentNutributionDict, preference_vector, category_encoding, snacks=0):
    string = ""
    if bool(set(tokenize_words(Ingredients).split(' ')).intersection(set(tokenize_words(Allegerie).split(' ')))):
        string = "Warning: The ingredients contain allergens"
    else:
        if not snacks:
            receipts = get_receipts(r"cleaned_data_with_allegery_meal.pkl", Ingredients, currentNutributionDict, preference_vector, category_encoding, 1)
        else:
            receipts = get_receipts(r"cleaned_data_with_allegery_snack.pkl", Ingredients, currentNutributionDict, preference_vector, category_encoding, 2)
        for index, i in enumerate(receipts):
            string += f"Receipt {index + 1}:\n"
            for j in i.keys():
                if j == 'Steps':
                    string += f"{j}:\n{i[j]}\n"
                else:
                    string += f"{j}: {i[j]}\n"
            string += "\n"
    return string

def calculate_max_daily_calories(height_cm, current_weight_lbs, target_weight_lbs, sex, age, days, activity_level='not knonwn'):
    current_weight_kg = current_weight_lbs / 2.20462
    target_weight_kg = target_weight_lbs / 2.20462

    if sex.lower() == 'm':
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

def dailyNutritions(Height, CurrentWeights, TargetWeights, time, sex, age):
    future_date = datetime.strptime(time, "%Y/%m/%d")
    today_date = datetime.now()
    days = (future_date - today_date).days
    daliyCal = calculate_max_daily_calories(Height, CurrentWeights, TargetWeights, sex, age, days)
    fat_max = daliyCal * 0.30 / 9
    cholesterol_max = 300
    sodium_max = 2300
    carbs_max = daliyCal * 0.55 / 4
    if sex == 'F':
        fiber_recommendation = 25
    else:
        fiber_recommendation = 38
    protein = CurrentWeights * 0.8
    sugar_max = daliyCal * 0.10 / 4  # 1 gram of sugar = 4 calories
    
    dailyNutritionLimitationDict = {'daliyCal': round(daliyCal, 2), 'fat': round(fat_max, 2), 'cholesterol': cholesterol_max, 'sodium': sodium_max, 'carbs': round(carbs_max, 2), 'fiber': fiber_recommendation, 'protein': protein, 'sugar': round(sugar_max, 2)}
    return dailyNutritionLimitationDict

def SysUse(file_path):
    read_data(file_path=file_path)
    clean_data()
    build_general_tfidf_model()
    df = pd.read_pickle('Receipts.pkl')
    lis = sorted(list(set((df['RecipeCategory']))))[1:]
    RecipeCategory = {Category: index for index, Category in enumerate(lis)}
    with open('RecipeCategory.pkl', 'wb') as f:
        pickle.dump(RecipeCategory, f)


# @app.route('/firstAccess', methods=['POST'])
# def first_access():
#     data = request.json
#     CurrentWeights = data.get('CurrentWeights')
#     TargetWeights = data.get('TargetWeights')
#     time = data.get('time')
#     sex = data.get('sex')
#     Allegerie = data.get('Allegerie')

#     nutritions = dailyNutritions(CurrentWeights, TargetWeights, time, sex)
#     build_customize_tfidf_model(Allegerie)



def first_access(Height, CurrentWeights, TargetWeights, time, sex, age, Allegerie, Preference):
    UserdailyNutritionLimitationDict = dailyNutritions(Height, CurrentWeights, TargetWeights, time, sex, age)
    with open('UserdailyNutrition.pkl', 'wb') as f:
        pickle.dump(UserdailyNutritionLimitationDict, f)
    build_customize_tfidf_model(Allegerie)
    initialize_preference_vector(Height, CurrentWeights, TargetWeights, sex, age, Preference)

