import pandas as pd
# import firebase_admin
from firebase_admin import credentials, storage, firestore
from utilities import encodeDF, divideString, recoverString

# cred = credentials.Certificate("cs125-healthapp-firebase-adminsdk-5vvud-3b42de41dd.json")
# app = firebase_admin.initialize_app(cred)
# db = firestore.client()

def is_numeric(s):
    try:
        float(s) 
        return True
    except ValueError:
        return False

def read_data(file_path):
    print("Begin to read database...")
    try:
        df = pd.read_csv(file_path, encoding='ISO-8859-1')
    except UnicodeDecodeError as e:
        print("Error with ISO-8859-1 encoding:", e)
        try:
            df = pd.read_csv(file_path, encoding='cp1252')
        except UnicodeDecodeError as e:
            print("Error with cp1252 encoding:", e)

    df = df.drop(['AuthorId', 'AuthorName', 'RecipeYield'], axis=1)
    df.dropna(subset=['RecipeIngredientParts'], inplace=True)
    df = df.drop(['RecipeId', 'DatePublished'], axis=1)
    df.dropna(subset=['RecipeIngredientQuantities'], inplace=True)
    df.dropna(subset=['RecipeCategory'], inplace=True)
    df.dropna(subset=['CookTime'], inplace=True)

    unwanted_substrings = ['https', 'jpg', 'jpeg', 'c("', '""', 'c_fit', '. ']
    df = df[~df['RecipeCategory'].apply(lambda x: any(sub in x for sub in unwanted_substrings))]
    df = df[df['RecipeCategory'].apply(lambda x: not x.replace(' ', '').isdigit())]
    df = df[~df['RecipeCategory'].str.contains("https|jpg|jpeg", case=False, na=False) & ~df['RecipeCategory'].apply(is_numeric)]
    df.reset_index(drop=True, inplace=True)

    Q = []
    for i, v in enumerate(df['RecipeIngredientQuantities']):
        if "NA" in v:
            v = v.replace(", NA", "").replace("NA", "")
        Q.append(v)

    df["RecipeIngredientQuantities"] = Q

    print("Finish Reading")

    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]

    df_string = encodeDF(df)

    update_database_dict = {"Receipts": df_string}

    return update_database_dict

# Only needs to run once when initializing the app
# database = read_data("/Users/zhanghaodong/Desktop/CS125-Project/Receipts.csv")
# parts = divideString(database["Receipts"], 1000)
# index = 0

# for i in parts:
#     db.collection("RecipeDataBase").document(f"RecipeData Part {index}").set({"Data": parts[i]})
#     index += 1

# string = ""
# start = time.time()
# for i in range(1000):
#     string += db.collection("RecipeDataBase").document(f"RecipeData Part {i}").get().to_dict()["Data"]
# print(string == database["Receipts"])
# print(time.time() - start)
