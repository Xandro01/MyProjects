# class Context: List<String> context_tokens, # HashMap<String, Integer> context_counts (token that follows the context)
from typing import List, Dict

class Context:
    def __init__(self, context_tokens: List[str] = None, context_counts: Dict[str, int] = None):
        if context_tokens is None:
            context_tokens = []
        if context_counts is None:
            context_counts = {}
        self.context_tokens = context_tokens
        self.context_counts = context_counts

    def __str__(self):
        return f"Context(tokens={self.context_tokens}, counts={self.context_counts})"
    
    def __eq__(self, value):
        #two contexts are equal if they have the same tokens in context_tokens
        for token in self.context_tokens:
            if token not in value.context_tokens:
                return False
        return True
            
    def update_counts(self, token: str):
        if token in self.context_counts:
            self.context_counts[token] += 1
        else:
            self.context_counts[token] = 1
    