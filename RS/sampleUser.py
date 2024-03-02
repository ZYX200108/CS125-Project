from pickle import load
from main import SysUse, first_access, recommend_function, dailyNutritions
from RSV1 import Read_data

def SampleDemo(Name, Height, CurrentWeights, TargetWeights, Time, Allegeries, Ingredients, Sex, Age, Preference, first=False):
    if first:
        SysUse(r"C:\Users\11429\Desktop\CS 125\Projects\Receipts.csv")
        first_access(Height, CurrentWeights, TargetWeights, Time, Sex, Age, Allegeries, Preference)
    else:
        with open('UserdailyNutrition.pkl', 'rb') as f:
            dailyNutritionLimitationDict = load(f)
        with open('RecipeCategory.pkl', 'rb') as f:
            category_encoding = load(f)
        with open('UserPreferenceModel.pkl', 'rb') as f:
            preference_vector = load(f)
        print(f'User {Name} Daily Nutrition Limitation')
        for i in dailyNutritionLimitationDict:
            print("{}: {}".format(i, dailyNutritionLimitationDict[i]))
        print()
        print(f'User {Name} Recommendations Meal based on Ingredients: {" ".join(Ingredients)} and Allegeries: {" ".join(Allegeries)}')
        receipts = recommend_function(Ingredients, Allegeries, currentNutributionDict=dailyNutritionLimitationDict, preference_vector=preference_vector, category_encoding=category_encoding)
        return receipts
    
# Sample User Coco
Name = 'Coco'
Height = 165 # cm
CurrentWeights = 198 # pounds
TargetWeights = 154 # pounds
Sex = 'F'
Age = 22
Target_date = '2024/06/15'
Allegeries = ['peanut', 'milk', 'wheat', 'shellfish']
Preference = ['Chicken', 'Fish Salmon']
Ingredients = ['chicken', 'onion', 'garlic', 'tomato', 'rice']
print(SampleDemo(Name, Height, CurrentWeights, TargetWeights, Target_date, Allegeries, Ingredients, Sex, Age, Preference, first=False))