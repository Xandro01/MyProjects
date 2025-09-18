# Si parte da un file xlsx dove sono presenti nelle righe 4 termini: Concreto-Generico, Concreto-Specifico, Astratto-Generico, Astratto-Specifico. Nelle colonne abbiamo N definizioni per ogni termine.
# Per ogni termine bisgona determinare un valore medio di similarità lessicale (simlex) e similarità semantica (simsem)
# Per simlex: 1) preprocessare le definizioni (stemming, rimozione stopwords), 2) calcolare la similarità lessicale utilizzando calcolo frequenze top-k parole più frequenti nelle definizioni e calcolare la copertura dividendo il numero di definizioni che contengono il termine nella top k per il numero totale di definizioni. Per calcolare le frequenze usa sklearn CountVectorizer
# Ottenendo così una stima della quantità di sovrapposizione lessicale
# Per simsem: 1) utilizziamo SentenceBERT per ottenere gli embeddings delle definizioni, 2) calcolare la cosine similarity tra gli embeddings delle definizioni e prendere la media
# Possiamo riempire una tabella che nelle righe ha Generico-Specifico e nelle colonne Concreto-Astratto, con i valori medi di simlex e simsem. Successivamente per confrontare Concreti-Astratti e Generico-Specifico prendiamoo la media dei valori nelle righe e nelle colonne
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


def simlex_top_k(lemmas, k=5):
    simlex = {
        'Pantalone': 0,
        'Microscopio': 0,
        'Pericolo': 0,
        'Euristica': 0
    }
    
    for term, definitions_list in lemmas.items():  
        vectorizer = CountVectorizer()
        # get the term frequency matrix (rows: definitions, columns: terms vocabulary) 
        # each cell contains the frequency of the specific term in the definition in CSR (Compressed Sparse Row) format
        # in order to convert it to a dense matrix use toarray() and tolist() to get a list of lists. Summing up: from (0, 2) 1, (0, 4) 1, (1, 1) 2 to [[0, 0, 1, 0, 1], [0, 2, 0, 0, 0], [1, 0, 0, 1, 0]]
        vector = vectorizer.fit_transform(definitions_list)
        total_sum = 0
        cont = 0
        for definition_count_vector in vector.toarray().tolist():
            #necessary to avoid comparing the same definition
            i = vector.toarray().tolist().index(definition_count_vector)
            #order in a crescent way and get the indices of the top-k most frequent words in x
            top_k_indices = np.argsort(definition_count_vector)[-k:]  
            for y in vector.toarray().tolist():
                j = vector.toarray().tolist().index(y)
                if i != j :
                    # Compute how much of the top-k words of definition_count_vector x are in definition_count_vector y
                    overlap = sum(1 for index in top_k_indices if y[index] > 0)
                    # Calculate the coverage as the overlap divided by k ( number of top-k words) quindi quante parole della top-k rispetto al totale sono presenti
                    total_sum += overlap / k
                    cont += 1
        simlex[term] = total_sum / cont if cont > 0 else 0
    return simlex

def simsem_cosine_similarity(definitions):
    simsem = {
        'Pantalone': 0,
        'Microscopio': 0,
        'Pericolo': 0,
        'Euristica': 0
    }
    
    # Load multilingual Sentence-BERT model
    model = SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')
    
    for term, definitions_list in definitions.items():
                    
        # Get embeddings for all definitions
        embeddings = model.encode(definitions_list)
        
        # Compute pairwise cosine similarities between embeddings (definition pairs)
        similarities = []
        for i in range(len(embeddings)):
            for j in range(i + 1, len(embeddings)):
                sim = cosine_similarity([embeddings[i]], [embeddings[j]])[0][0]
                similarities.append(sim)
        
        # Calcola la media delle similarità
        simsem[term] = np.mean(similarities) if similarities else 0
    
    return simsem


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


if __name__ == '__main__':
    #load xlsx file
    terms_definitions = load_definitions_from_file('/home/patric/Documents/nltktest/TLN24-25/EserciziTerzaParte/Esercizio2/dataset_definizioni_TLN_25.xlsx')
    
    #remove stopwords, lemmatize for simlex
    data = data_processing(terms_definitions)
    #calculate simlex
    simlex_similarity_dict = simlex_top_k(data, k=7)
    #calculate simsem
    simsem_similarity_dict = simsem_cosine_similarity(terms_definitions)
    
    # Plotting results in a table 2x2 with rows Generico-Specifico and columns Concreto-Astratto
    results = pd.DataFrame(index=['Generico', 'Specifico'], columns=['Astratto', 'Concreto'])
    results.loc['Generico', 'Astratto'] = (round(simlex_similarity_dict['Pericolo'], 4), round(simsem_similarity_dict['Pericolo'], 4))
    results.loc['Generico', 'Concreto'] = (round(simlex_similarity_dict['Pantalone'], 4), round(simsem_similarity_dict['Pantalone'], 4))
    results.loc['Specifico', 'Astratto'] = (round(simlex_similarity_dict['Euristica'], 4), round(simsem_similarity_dict['Euristica'], 4))
    results.loc['Specifico', 'Concreto'] = (round(simlex_similarity_dict['Microscopio'], 4), round(simsem_similarity_dict['Microscopio'], 4))
    
    # results in the format (simlex, simsem)
    print("\nResults in the format (simlex, simsem):\n")
    print(results)
    print("\n")
    
    
    # Calculate averages to compare Concreto vs Astratto and Generico vs Specifico
    avg_generico_simlex = np.mean([results.loc['Generico', 'Astratto'][0], results.loc['Generico', 'Concreto'][0]])
    avg_generico_simsem = np.mean([results.loc['Generico', 'Astratto'][1], results.loc['Generico', 'Concreto'][1]])
    avg_specifico_simlex = np.mean([results.loc['Specifico', 'Astratto'][0], results.loc['Specifico', 'Concreto'][0]])
    avg_specifico_simsem = np.mean([results.loc['Specifico', 'Astratto'][1], results.loc['Specifico', 'Concreto'][1]])

    print(f"Average Generico SimLex: {avg_generico_simlex:.4f}, SimSem: {avg_generico_simsem:.4f}")
    print(f"Average Specifico SimLex: {avg_specifico_simlex:.4f}, SimSem: {avg_specifico_simsem:.4f}")
    print("\n")
    avg_concreto_simlex = np.mean([results.loc['Generico', 'Concreto'][0], results.loc['Specifico', 'Concreto'][0]])
    avg_concreto_simsem = np.mean([results.loc['Generico', 'Concreto'][1], results.loc['Specifico', 'Concreto'][1]])
    avg_astratto_simlex = np.mean([results.loc['Generico', 'Astratto'][0], results.loc['Specifico', 'Astratto'][0]])
    avg_astratto_simsem = np.mean([results.loc['Generico', 'Astratto'][1], results.loc['Specifico', 'Astratto'][1]])

    print(f"Average Concreto SimLex: {avg_concreto_simlex:.4f}, SimSem: {avg_concreto_simsem:.4f}")
    print(f"Average Astratto SimLex: {avg_astratto_simlex:.4f}, SimSem: {avg_astratto_simsem:.4f}")
    print("\n")

    # Commento sui risultati
    """
    Dai risultati ottenuti possiamo osservare che soprattutto per la similarità lessicale, 
    i valori medi per i termini concreti sono più alti rispetto a quelli astratti.
    Questo suggerisce che le definizioni di termini concreti tendono a condividere più parole comuni,
    probabilmente perché descrivono oggetti o concetti tangibili che sono più facilmente rappresentabili 
    con un vocabolario specifico e condiviso.
    
    """