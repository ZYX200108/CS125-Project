import nltk
import unidecode
import pandas as pd

def clean_data():
    nltk.download('wordnet')
    df = pd.read_pickle("Receipts.pkl")

    print("Begin to clean data...")
    ingredients = []
    words_to_remove = []
    vocb = nltk.FreqDist()
    for ingredient in df['RecipeIngredientParts']:
        items = ingredient[2:-1].split('", "')
        words = [word for item in items for word in item.strip('"').split(' ')]
        ingredients.append(words)
        vocb.update(words)

    for word, frequency in vocb.most_common(200):
        if frequency > 150000:
            words_to_remove.append(word)

    stemmer = nltk.stem.porter.PorterStemmer()
    lemmatizer = nltk.stem.WordNetLemmatizer()
    clean_text = []
    for i, words in enumerate(ingredients):
        words = [unidecode.unidecode(word.lower()) for word in words if word.isalpha()]
        words = [lemmatizer.lemmatize(stemmer.stem(word)) for word in words]
        ingredients[i] = [word for word in words if word not in words_to_remove]
        clean_text.append(' '.join(ingredients[i]))
    print("Finish cleaning")

    df['Ingredients'] = clean_text
    df.to_pickle("cleaned_data.pkl")

def tokenize_words(words):
    # Stemming and Lemmatization
    words_to_remove = ['salt', 'sugar', 'pepper', 'fresh']
    stemmer = nltk.stem.porter.PorterStemmer()
    lemmatizer = nltk.stem.WordNetLemmatizer()
    clean_text = []
    words = [unidecode.unidecode(word.lower()) for word in words if word.isalpha()]
    words = [lemmatizer.lemmatize(stemmer.stem(word)) for word in words]
    words = [word for word in words if word not in words_to_remove]
    clean_text = ' '.join(words)
    return clean_text

