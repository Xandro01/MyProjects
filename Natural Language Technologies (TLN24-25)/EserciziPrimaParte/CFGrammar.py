from nltk import CFG
from CKY import CKY
from CKY import printTree

#load grammar from file in CF_Grammars directory

grammars_directory = "CF_Grammars"

grammar = CFG.fromstring(open(grammars_directory + "/L1.cfg").read())
quenya_grammar = CFG.fromstring(open(grammars_directory + "/quenya.cfg").read())


grammar = grammar.chomsky_normal_form()
quenya_grammar = quenya_grammar.chomsky_normal_form("-")

#result = CKY(["book", "the", "flight", "through", "Houston"], grammar)
#result = CKY(["does", "she", "prefer", "a", "morning", "flight"], grammar)


#result = CKY(["i", "hesto", "samë", "macil"], quenya_grammar)
#result = CKY(["i", "aran", "tíra", "aiwi"], quenya_grammar)
result = CKY(["nanye", "lumba"], quenya_grammar)
#result = CKY(["nálmë", "eldar"], quenya_grammar)
#result = CKY(["i", "atan", "antanë", "i", "eldan", "tecil"], quenya_grammar)


result.print()
printTree(result)



