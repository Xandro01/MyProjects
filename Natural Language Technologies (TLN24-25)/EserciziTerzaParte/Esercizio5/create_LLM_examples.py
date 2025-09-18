# Ricerca onomosiologica, dal contenuto alla forma
# Partendo dalle definizioni che abbiamo cerchiamo di ottenere il synset di WordNet che meglio rappresenta il termine.
# Si utilizza il principio di genus et differentia specifica, ovvero si cerca il synset che contiene nella definizione la parola più frequente nelle nostre definizioni.
# Per fare questo si calcola la frequenza delle parole nelle definizioni e si prendono le k più frequenti (top-k).
# I termini più frequenti nelle definizioni spesso sono i genus, ovvero la categoria più generale a cui appartiene il termine. Questi in genere sono gli iperonimi. 
# Li cerchiamo in WordNet e cerchiamo tra i suoi iponimi quello più simile alla nostra definizione secondo simsem con sentence BERT.
import nltk
nltk.download('stopwords')
import spacy
import pandas as pd
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import CountVectorizer
import string
import numpy as np
import matplotlib.pyplot as plt
from nltk.corpus import wordnet as wn

nlp = spacy.load("it_core_news_sm")
 

                        


def data_processing(terms_definitions):
    terms_normalized = {
        'Pantalone': [],
        'Microscopio': [],
        'Pericolo': [],
        'Euristica': []
    }
    
    stop = set(stopwords.words('italian') + list(string.punctuation) + ["``",  "''"])
    
    for key, values in terms_definitions.items():
        for definition in values:
            nlp_def = nlp(definition.lower())
            # word tokenization, stopword removal, lemmatization with spacy
            lemmas = [token.lemma_ for token in nlp_def if token.text not in stop]
            # join lemmas to a single string
            definition_lematized = " ".join(lemmas)
            terms_normalized[key].append(definition_lematized)
    return terms_normalized

# Find Genus
def terms_top_k_in_definitions(lemmas, k=5):
    # Dict: Term -> list of top-k most frequent words in its definitions
    top_k_definition_terms = {
        'Pantalone': [],
        'Microscopio': [],
        'Pericolo': [],
        'Euristica': []
    }
    
    for term, definitions_list in lemmas.items():  
        vectorizer = CountVectorizer()
        # get the term frequency matrix (rows: definitions, columns: terms vocabulary) 
        # each cell contains the frequency of the specific term in the definition in CSR (Compressed Sparse Row) format
        vector = vectorizer.fit_transform(definitions_list)
        # Sum each column to get the total frequency of each term across all definitions and get top-k most frequent words in all definitions
        total_count = np.sum(vector.toarray(), axis=0)
        # order in a descending way (thanks to [::-1]) and get the indices of the top-k most frequent words in total_count
        top_k_indices = np.argsort(total_count)[::-1][:k]
        # create a dict like this: {term: name, count: frequency}
        terms_name_frequency = [{ 'term': vectorizer.get_feature_names_out()[i], 'count': str(total_count[i])} for i in top_k_indices]
        
        top_k_words = [vectorizer.get_feature_names_out()[i] for i in top_k_indices]
        top_k_definition_terms[term] = terms_name_frequency 
    
    return top_k_definition_terms


def load_definitions_from_file(filepath):
    df = pd.read_excel(filepath)  
    terms = {
        'Pantalone': [],
        'Microscopio': [],
        'Pericolo': [],
        'Euristica': []
    }
    
    for _, row in df.iterrows():
        term = row["Termine"]  
        definitions = row[2:].dropna().tolist()  
        terms[term] = definitions
    return terms


if __name__ == "__main__":
    #load xlsx file
    terms_definitions = load_definitions_from_file('/home/patric/Documents/nltktest/TLN24-25/EserciziTerzaParte/Esercizio2/dataset_definizioni_TLN_25.xlsx')
    
    #remove stopwords, lemmatize for simlex
    data = data_processing(terms_definitions)
    
    #get top-k most frequent words in definitions
    word_top_k_terms_dict = terms_top_k_in_definitions(data, k=4)
    
    #save word_top_k_terms_dict to a json file
    import json 
    output_filepath = '/home/patric/Documents/nltktest/TLN24-25/EserciziTerzaParte/Esercizio3'
    with open(f'{output_filepath}/top_k_terms_in_definitions.json', 'w', encoding='utf-8') as f:
        json.dump(word_top_k_terms_dict, f, indent=4, ensure_ascii=False)
    
    print("SAVED top_k_terms_in_definitions.json")
