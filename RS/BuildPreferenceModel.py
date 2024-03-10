import numpy as np
from utilities import encodeDF, decode2df, divideString

def initialize_preference_vector(db, user_name, height, current_weight, target_weight, sex, age, preference):
    categories_encoding = db.collection("RecipeCategory").document(f"RecipeCategory").get().to_dict()["Data"]
    sex_encoding = {'M': 0, 'F': 1}

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

def update_preference_vector(db, user_name, receipts, which, meal=True):
    preference_vector = db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").get().to_dict()["Data"]
    category_encoding = db.collection("RecipeCategory").document(f"RecipeCategory").get().to_dict()["Data"]
    if meal:
        string = ""
        for i in range(1000):
            string += db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {i}").get().to_dict()["Data"]
        df = decode2df(string)
    else:
        string = ""
        for i in range(1000):
            string += db.collection("users").document(user_name).collection("CleanSnackRecipes").document(f"CleanData Part {i}").get().to_dict()["Data"]
        df = decode2df(string)
    indexs = list(receipts.index)
    indexs_ignore = np.array(indexs[: which] + indexs[which+1:])
    df.iloc[indexs_ignore, df.columns.get_loc('RepeatIgnore')] += 1
    df.iloc[indexs_ignore, df.columns.get_loc('RepeatChoose')] = 0
    df.iloc[which, df.columns.get_loc('RepeatChoose')] += 1
    df.iloc[which, df.columns.get_loc('RepeatIgnore')] = 0

    receipts_categories = list(receipts['RecipeCategory'])
    need = receipts_categories[which]
    categories_ignore = np.array(receipts_categories[: which] + receipts_categories[which+1:])
    for index, i in enumerate(categories_ignore):
        preference_vector[category_encoding[i]] = max(0, preference_vector[category_encoding[i]] - 0.03 * df.iloc[indexs_ignore[index], df.columns.get_loc('RepeatIgnore')])
    preference_vector[category_encoding[need]] = min(1, preference_vector[category_encoding[i]] + 0.03 * df.iloc[indexs_ignore[which], df.columns.get_loc('RepeatIgnore')])

    if meal:
        meal_string = encodeDF(df)
        meal_parts = divideString(meal_string, 1000)
        index = 0
        for i in meal_parts:
            db.collection("users").document(user_name).collection("CleanMealRecipes").document(f"CleanData Part {index}").set({"Data": meal_parts[i]})
    else:
        snack_string = encodeDF(df)
        snack_parts = divideString(snack_string, 1000)
        index = 0
        for i in snack_parts:
            db.collection("users").document(user_name).collection("CleanSnackRecipes").document(f"CleanData Part {index}").set({"Data": snack_parts[i]})

    db.collection("users").document(user_name).collection("PreferenceVector").document("PreferenceVector").set({"Data": preference_vector})


    
    