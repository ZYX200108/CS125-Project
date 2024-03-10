import base64
import pandas
import pickle
from io import BytesIO

def encodeDF(df: pandas.DataFrame) -> str:
    pickle_string = pickle.dumps(df)
    encoded_data = base64.b64encode(pickle_string)
    base64_string = encoded_data.decode('utf-8')
    return base64_string

def decode2df(base64_string: str) -> pandas.DataFrame:
    encoded_data = base64_string.encode('utf-8')
    pickle_string = base64.b64decode(encoded_data)
    df = pandas.read_pickle(BytesIO(pickle_string))
    return df

def are_dataframes_equal(df1: pandas.DataFrame, df2: pandas.DataFrame, check_index: bool = True) -> bool:
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
    # length = len(string) // n
    # parts = {}
    # for i in range(n):
    #     parts[f'Recipes Part {i}'] = string[i * length: (i + 1) * length]
    # return parts
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