import pandas as pd
from utilities import encodeDF, decode2df, are_dataframes_equal

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

    # The code to update the dict


