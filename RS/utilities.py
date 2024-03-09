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