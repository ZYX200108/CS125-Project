from RSV1 import get_receipts
from ReadData import read_data
from DataClean import tokenize_words, clean_data
from BuildTFIDFModel import build_customize_tfidf_model, build_general_tfidf_model, update_customize_tfidf_model

def main(Ingredients, Allegerie, snacks=0):
    string = ""
    if bool(set(tokenize_words(Ingredients).split(' ')).intersection(set(tokenize_words(Allegerie).split(' ')))):
        string = "Warning: The ingredients contain allergens"
    else:
        if not snacks:
            receipts = get_receipts(r"cleaned_data_with_allegery_meal.pkl", Ingredients, 1)
        else:
            receipts = get_receipts(r"cleaned_data_with_allegery_snack.pkl", Ingredients, 2)
        for index, i in enumerate(receipts):
            string += f"Receipts {index + 1}:\n"
            for j in i.keys():
                if j == 'Steps':
                    string += f"{j}:\n{i[j]}\n"
                else:
                    string += f"{j}: {i[j]}\n"
            string += "\n"
    return string

def daliyNutritions(CurrentWeights, TargetWeights, time, sex):
    difference = CurrentWeights - TargetWeights
    daliyCal = difference * 3500 / time
    breakfastCal = round(daliyCal * 0.25)
    lunchCal = round(daliyCal * 0.40)
    dinnerCal = round(daliyCal * 0.35)
    daliyCal = breakfastCal + lunchCal + dinnerCal
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
    
    dictionary = {'daliyCal': daliyCal, 'fat_max': fat_max, 'cholesterol_max': cholesterol_max, 'sodium_max': sodium_max, 'carbs_max': carbs_max, 'fiber_recommendation': fiber_recommendation, 'protein': protein, 'sugar_max': sugar_max}
    return dictionary

def SysUse(file_path):
    read_data(file_path=file_path)
    clean_data()
    build_general_tfidf_model()

def firstAccess(Allegerie):
    build_customize_tfidf_model(Allegerie)

Allegeries = ['peanut', 'milk', 'wheat', 'shellfish']
Ingredients = ['chicken', 'onion', 'garlic', 'tomato', 'rice']
receipts = main(Ingredients, Allegeries)
print(receipts)