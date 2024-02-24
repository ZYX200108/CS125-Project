from main import SysUse, first_access, recommend_function, dailyNutritions
from RSV1 import Read_data

def SampleDemo(Name, Height, CurrentWeights, TargetWeights, Time, Allegeries, Ingredients, Sex, Age, first=False):
    if first:
        SysUse('Receipts.csv')
        dailyNutritionLimitationDict = first_access(Height, CurrentWeights, TargetWeights, Time, Sex, Age, Allegeries)
        return dailyNutritionLimitationDict
    else:
        dailyNutritionLimitationDict = dailyNutritions(Height, CurrentWeights, TargetWeights, Time, Sex, Age)
        print(f'User {Name} Daily Nutrition Limitation')
        for i in dailyNutritionLimitationDict:
            print("{}: {}".format(i, dailyNutritionLimitationDict[i]))
        print()
        print(f'User {Name} Recommendations Meal based on Ingredients: {" ".join(Ingredients)} and Allegeries: {" ".join(Allegeries)}')
        receipts = recommend_function(Ingredients, Allegeries, currentNutributionDict=dailyNutritionLimitationDict)
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
Ingredients = ['chicken', 'onion', 'garlic', 'tomato', 'rice']
print(SampleDemo(Name, Height, CurrentWeights, TargetWeights, Target_date, Allegeries, Ingredients, Sex, Age, first=False))