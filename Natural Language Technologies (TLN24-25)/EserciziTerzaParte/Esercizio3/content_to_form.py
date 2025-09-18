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
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import CountVectorizer
import string
import numpy as np
from sentence_transformers import SentenceTransformer
import matplotlib.pyplot as plt
from nltk.corpus import wordnet as wn

nlp = spacy.load("it_core_news_sm")
 
# find best synset for each term using top-k most frequent words in definitions 
# to find genus in wordnet and then get all its hyponyms to find
# the best one using simsem with sentence BERT
def search_synset(word_top_k_terms_dict, terms_definitions):
    # Dict: Term -> best synset.name
    terms_normalized = {
        'Pantalone': {"Sysnet Name": "", "Definition": "", "AVG Similarity": 0},
        'Microscopio': {"Sysnet Name": "", "Definition": "", "AVG Similarity": 0},
        'Pericolo': {"Sysnet Name": "", "Definition": "", "AVG Similarity": 0},
        'Euristica': {"Sysnet Name": "", "Definition": "", "AVG Similarity": 0},
    }
    
    for term, top_k_words in word_top_k_terms_dict.items():
        #for each of the top-k words search synsets in wordnet
        #global max average similarity
        max_avg_sim_top_k = -1
        for word in top_k_words:
            genus_term = wn.synsets(word, lang='ita', pos=wn.NOUN)
            if genus_term:
                #get the first synset (most common)
                genus_term = genus_term[0]
                #get all hyponyms of the genus term
                hyponyms = genus_term.hyponyms()
                if hyponyms:
                    #for each hyponym get its definition and compute simsem with all definition (in terms_definition) sentence BERT
                    best_hyponym = None
                    # local max average similarity for this genus term
                    max_avg_sim_hyp = -1
                    for hyponym in hyponyms:
                        hyponym_definition = hyponym.definition()
                        term_definitions = terms_definitions[term]
                        avg_sim = get_avg_cosine_similarity_between_hyponym_and_definitions(hyponym_definition, term_definitions)
                        if avg_sim > max_avg_sim_hyp:
                            max_avg_sim_hyp = avg_sim
                            best_hyponym = hyponym
                            
                    #update global max average similarity
                    if best_hyponym:    
                        if max_avg_sim_hyp > max_avg_sim_top_k:
                            max_avg_sim_top_k = max_avg_sim_hyp
                            #update the best hyponym for the term
                            terms_normalized[term]["Sysnet Name"] = best_hyponym.name()
                            terms_normalized[term]["Definition"] = best_hyponym.definition()
                            terms_normalized[term]["AVG Similarity"] = max_avg_sim_top_k
                    print(f"Current best hyponym for term '{term}' using genus '{word}': {best_hyponym.name()} with avg similarity {max_avg_sim_hyp}")

    return terms_normalized

                        
# Compute cosine similarity between hyponym definition embedding
# and all definitions embeddings and take the average
def get_avg_cosine_similarity_between_hyponym_and_definitions(hyponym_definition, term_definitions):
    # Load multilingual Sentence-BERT model
    model = SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')
    
    # Get embedding for hyponym definition
    hyponym_embedding = model.encode(hyponym_definition)
    # Get embeddings for all term definitions
    definitions_embeddings = model.encode(term_definitions)
    
    similarities = []
    for i in range(len(definitions_embeddings)):
        sim = cosine_similarity([hyponym_embedding], [definitions_embeddings[i]])[0][0]
        similarities.append(sim)
        
    return np.mean(similarities) if similarities else 0

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
        top_k_words = [vectorizer.get_feature_names_out()[i] for i in top_k_indices]
        top_k_definition_terms[term] = top_k_words
    
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
    word_top_k_terms_dict = terms_top_k_in_definitions(data, k=3)
    print(f"\nTop-k most frequent words in definitions: {word_top_k_terms_dict}\n")
    search_results = search_synset(word_top_k_terms_dict, terms_definitions)
    print(search_results)