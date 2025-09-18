
# We start from a corpus of sentence, the process is: 1) get n sentences from the corpus
# 2) for each word of a sentence get all lexical unit that activate a frame in framenet
# 3) get the synsets in wordnet associated to the word through nltk simple Lesk algorithm using the sentence context and wordnet examples in order to get overlap
# 4) for each synset get the definition and the examples
# 5) store the result in a json file
# 
# Obiettivo: i LU attivano frame in framenet, associare a questi LU i synset di wordnet attraverso l'algoritmo di Lesk consente di aiutare l'annotatore nella scelta del frame corretto in presenza di un lu con più frame associati
import nltk

from nltk.wsd import lesk
import pandas as pd
import json
import random
from graphviz import Digraph

nltk.data.path.append('./nltk_data/')

# Corpus download
nltk.download('framenet_v17')
nltk.download('wordnet')
nltk.download('brown')
nltk.download('averaged_perceptron_tagger_eng')
nltk.download('punkt')

from nltk.corpus import framenet as fn
from nltk.corpus import wordnet as wn

from nltk.corpus import brown

# get a dictionary where the keys are the lexical units and the values are: the frames they activate, the synsets: name, definition, examples
# es: {"run.v": {"frames": ["Self_motion", "Operating_a_system"], "synsets": [{"name": "run.v.01", "definition": "move fast by using one's feet", "examples": ["the children ran to the store"]}, {"name": "run.v.02", "definition": "function or cause to function", "examples": ["The new computer runs faster than the old one"]}]}}
def get_sentences_lexical_units_and_frame(sentence, lesk_sentence_context):
    
    words_frame_synset_info = []
    
    #get all lexical units in the pos tagged sentence
    for word in sentence:
        lexical_units_frames_activated = {"word": word, "frames": [], "synset": {}}
            
        lus = fn.lus(name=word)
        # inside lus there is a list of lexical units that can activate different frames. E' possibile avere più elementi uguali in questa lista es "run.v" -> [run.v (frame: Self_motion), run.v (frame: Operating_a_system)] che attivano frame diversi
        if lus:
            for lu in lus:
                # get the frame activated by the lu
                frame = lu.frame
        
                lexical_units_frames_activated["frames"].append({"name": frame.name, "definition": frame.definition})
        else:
            lexical_units_frames_activated["frames"].append(None)
            lexical_units_frames_activated["synset"] = {}
            continue
                      
        # remove pos tag in the word and call the function that get the synset using lesk algorithm
        # dont'consider last 2 characters (pos tag)
        word_no_pos = word[:-2]
        lexical_units_frames_activated["synset"] = get_word_synset_definition_examples(word_no_pos, lesk_sentence_context)
        words_frame_synset_info.append(lexical_units_frames_activated)
        
    return words_frame_synset_info

def get_word_synset_definition_examples(lesk_sentence_context, word):
    # simple lesk algorithm (overlap with wordnet gloss + examples) (risultati scarsi rispetto metodi come embeddings e cosine similarity)
    synset = lesk(word, lesk_sentence_context)
    if synset:
        definition = synset.definition()
        examples = synset.examples()
        return {"Name": synset.name(), "Definition": definition, "Examples": examples}
    else:
        return {"Word": word, "Synset": None}
    
def json_to_graphviz_tree(dot, json_file_path, output_file='tree_visualization'):
    with open(json_file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    dot.attr(rankdir='TB', size='12,20')  
    dot.attr('node', fontsize='14', width='1.5', height='0.8')  
    dot.attr('edge', fontsize='12')
    

    dot.attr(nodesep='0.5')  
    dot.attr(ranksep='1.5') 
    # Nodo radice
    root_id = "sentence"
    dot.node(root_id, f"Sentence\n{data['Sentence'][:30]}...", 
             shape='box', style='filled', fillcolor='lightgreen')
    
    for i, word_info in enumerate(data["Words_frame_and_synset"]):
        word_id = f"word_{i}"
        dot.node(word_id, f"Word\n{word_info['word']}", 
                shape='ellipse', style='filled', fillcolor='lightblue')
        dot.edge(root_id, word_id)
        
        # Frames
        if word_info["frames"] and word_info["frames"][0]:
            for j, frame in enumerate(word_info["frames"]):
                if frame:
                    frame_id = f"frame_{i}_{j}"
                    dot.node(frame_id, f"Frame\n{frame['name']}", 
                            shape='box', style='filled', fillcolor='yellow')
                    dot.edge(word_id, frame_id)
        
        # Synset
        if word_info["synset"] and "Name" in word_info["synset"]:
            synset_id = f"synset_{i}"
            dot.node(synset_id, f"Synset\n{word_info['synset']['Name']}", 
                    shape='diamond', style='filled', fillcolor='orange')
            dot.edge(word_id, synset_id)

if __name__ == "__main__":
    # Get n sentences from the Brown corpus
    num_sentences = 1
    
    # get num_sentences sentences randomly from the Brown corpus
    sentences_tokenized = list(brown.sents()) # brown.sents() returns a generator (one sentence at a time)
    selected_sentences = random.sample(sentences_tokenized, num_sentences)
    
    lemmatizer = nltk.WordNetLemmatizer()
    for i, sent in enumerate(selected_sentences):
        pos_tagged = nltk.pos_tag(sent)
        
        # convert tokenized sentence into a new list where each token is lemmatized and pos tagged es "I am running" -> ["I", "be.v", "run.v"]
        lemmatized_and_pos_tagged = []
        
        #contex without pos tag for Lesk algorithm
        lesk_sentence_context = [w.lower() for w in sent]
        
        for word, pos in pos_tagged:
            w = word.lower()
            if pos.startswith('N'):
                lemmatized_and_pos_tagged.append(lemmatizer.lemmatize(w, pos='n') + '.n')
            if pos.startswith('V'):
                lemmatized_and_pos_tagged.append(lemmatizer.lemmatize(w, pos='v') + '.v')
            if pos.startswith('J'):
                lemmatized_and_pos_tagged.append(lemmatizer.lemmatize(w, pos='a') + '.a')
            if pos.startswith('R'):
                lemmatized_and_pos_tagged.append(lemmatizer.lemmatize(w, pos='r') + '.r')
                
        print(f"Lemmatized and POS tagged: {lemmatized_and_pos_tagged}")
        
        # get the lexical units and the frames they activate
        sentence_frame_sysnsets = {
            "Sentence": " ".join(sent), 
            "Words_frame_and_synset": get_sentences_lexical_units_and_frame(lemmatized_and_pos_tagged, lesk_sentence_context)
        }
        
        # save the result in a json file
        with open(f'sentence_{i+1}_frames_synsets.json', 'w', encoding='utf-8') as f:
            json.dump(sentence_frame_sysnsets, f, indent=4, ensure_ascii=False)
        print(f"Results saved in sentence_{i+1}_frames_synsets.json")
        
        dot = Digraph(comment='Frame disambiguation Tree')
        # create a tree graph visualization from the json file and save it in a pdf file
        json_to_graphviz_tree(dot, f'sentence_{i+1}_frames_synsets.json', output_file=f'sentence_{i+1}_tree')
        
        # render the graph to a file
        dot.render(f'sentence_{i+1}_tree', format='pdf', cleanup=True)
        print(f"Tree visualization saved in sentence_{i+1}_tree.pdf")
        
        
  
     
        
        
