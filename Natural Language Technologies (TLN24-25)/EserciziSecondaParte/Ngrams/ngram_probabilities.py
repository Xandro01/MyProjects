from context import Context
from typing import List, Dict, Tuple
import random
import numpy as np

class NgramProbabilityMatrix:
    def __init__(self, vocabulary:List[str], ngram_contexts: List[Context]):
        self.vocabulary = vocabulary
        self.ngram_contexts = ngram_contexts
        self.vocabulary_size = len(vocabulary)
        #self.matrix = self.calculate_probabilities()

    """
    def calculate_probabilities(self):
        matrix = []
        # Initialize matrix with zeros
        for _ in range(self.vocabulary_size):
            matrix.append([0] * len(self.ngram_contexts))
        
        # Calculate probabilities for each n-gram context with Laplace smoothing C(w|C) = (C(w|C) + 1) / (C(C) + V)  where C(w|C) is the count of word w given context C, C(C) is the count of context C (sum of counts of all words in context C) and V is the vocabulary size
        for j, context in enumerate(self.ngram_contexts):
            context_count = sum(context.context_counts.values())
            for i, token in enumerate(self.vocabulary):
                count_w_given_C = context.context_counts.get(token)
                # Laplace smoothing
                probability = (count_w_given_C + 1) / (context_count + self.vocabulary_size)
                matrix[i][j] = probability
                
        return matrix
    """
    
    def calculate_probabilities_on_the_fly(self, context: Context):
        """
        Calculate probabilities for a given context on the fly.
        
        Args:
            context (Context): Context object containing tokens and counts
            
        Returns:
            List[float]: List of probabilities for each word in the vocabulary
        """
        #print(f"Calculating probabilities for context: {context.context_tokens}")
        
        
        if(context in self.ngram_contexts):
            context_index = self.ngram_contexts.index(context)
            context = self.ngram_contexts[context_index]
        
        context_count = sum(context.context_counts.values())
        probabilities = []
        for token in self.vocabulary:
            count_w_given_C = context.context_counts.get(token, 0)
            # Laplace smoothing
            probability = (count_w_given_C + 1) / (context_count + self.vocabulary_size)
            probabilities.append(probability)
            
        #print sorted probabilities
        sorted_probabilities = sorted(probabilities, reverse=True)
        #print(f"Sorted probabilities for context {context.context_tokens}: {sorted_probabilities[:10]}")
   
        #print top 10 probabilities and associated words
        sorted_indices = sorted(range(len(probabilities)), key=lambda i: probabilities[i], reverse=True)
        sorted_words = [self.vocabulary[i] for i in sorted_indices[:10]]
        #print(f"Top 10 words for context {context.context_tokens}: {sorted_words}")
        return probabilities

    def __str__(self):
        return f"NgramProbabilityMatrix(vocabulary={self.vocabulary}, ngram_contexts={self.ngram_contexts} \nmatrix={self.matrix})"
    
    def get_word_maximize_ngram_probability(self, context:Context):
        """
        Get the word that maximizes the n-gram probability for the given context.
        
        Args:
            context (Context): Context object containing tokens and counts
            
        Returns:
            str: Word that maximizes the n-gram probability
        """
        probabilities = self.calculate_probabilities_on_the_fly(context)
        
        max_index = probabilities.index(max(probabilities))
        
        return self.vocabulary[max_index]
        
    
    def get_word_with_temperature(self, context: Context, temperature=1.0):
        probabilities = self.calculate_probabilities_on_the_fly(context)
        
        if temperature == 0:
            max_index = probabilities.index(max(probabilities))
            return self.vocabulary[max_index]
        
        # Apply temperature scaling
        import numpy as np
        scaled_probs = np.array(probabilities) ** (1.0 / temperature)
        
        # Normalize the probabilities in order to sum to 1
        scaled_probs = scaled_probs / np.sum(scaled_probs)
        
        # Sample from distribution
        chosen_index = np.random.choice(len(probabilities), p=scaled_probs)
        return self.vocabulary[chosen_index]
