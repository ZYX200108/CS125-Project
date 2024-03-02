import pickle
import numpy as np
from RSV1 import Read_data

def initialize_preference_vector(height, current_weight, target_weight, sex, age, preference):
    with open('RecipeCategory.pkl', 'rb') as f:
        categories_encoding = pickle.load(f)
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
    with open('UserPreferenceModel.pkl', 'wb') as f:
        pickle.dump(preference_vector, f)

def update_preference_vector(receipts, file_path, which):
    with open('UserPreferenceModel.pkl', 'rb') as f:
        preference_vector = pickle.load(f)
    with open('RecipeCategory.pkl', 'rb') as f:
        category_encoding = pickle.load(f)
    df = Read_data(file_path)
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

    df.to_pickle(file_path)
    with open('UserPreferenceModel.pkl', 'wb') as f:
        pickle.dump(preference_vector, f)



    
    