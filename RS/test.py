import pandas as pd
import numpy as np

# Sample DataFrame
data = {'Name': ['John', 'Anna', 'Peter', 'Linda'],
        'Age': [28, 34, 29, 32]}
df = pd.DataFrame(data)

# Add a new column with default value 0
df['NewColumn'] = 0

a = np.array([0,2])

df.iloc[a, df.columns.get_loc('NewColumn')] += 1
print(df)