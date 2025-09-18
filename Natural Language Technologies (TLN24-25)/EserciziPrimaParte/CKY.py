from typing import List
from typing import Set
from nltk import CFG
from multiset import *
from graphviz import Digraph
import os

class Node:  

    def __init__(self, label: str, node1 = None, node2 = None):
        self.label = label
        self.children = []
        if(node1):
            self.addChildren(node1)
        if(node2):
            self.addChildren(node2)
            
    def isTerminal(self):
        return len(self.children) == 0
    
    def addChildren(self, node):
        if(len(self.children) > 1):
            raise Exception("Troppi figli")
        self.children.append(node)
    
    def setLabel(self, label):
        self.label = label
    def __str__(self):
        # string =  f"{self.label}(" + str(self.children) + ")"
        string =  f"{self.label}"
        return string
    
    def __repr__(self):
        return self.__str__()
    
    def __hash__(self):
        return hash(self.label)
    
   # def __eq__(self, value):
       # return self.label == value.label
    
class Table:
    
    def __init__(self, lenght: int):
        self.elements = [] 
        for x in range(int((lenght*(lenght+1)) / 2) ):
            self.elements.append(set())
            
        self.len = lenght
        self.sentence_count = 0
    
    def indexOf(self, i, j):
        return ((2*self.len - i + 1) * i) // 2 + (j - i)
    
    def getLength(self):
        return self.len
    
    def get(self, i: int, j: int):
        if(i > j):
            raise Exception("Indice non valido")
        return self.elements[self.indexOf(i,j)]
    
    def getElement(self, label, i: int, j: int):
        if(i > j):
            raise Exception("Indice non valido")
        
        check_contains, elementSet = self.contains(label, i, j)
        if check_contains:
            return elementSet
        
        return None
        #for elementSet in self.elements[self.indexOf(i,j)]:
         #   if(elementSet.label == label):
          #      return elementSet
    
    def insert(self, node: Node, i: int, j: int):
        if(i > j):
            raise Exception("Indice non valido")
            
        #if there are no elements with same label, add the node
        """if(node.label == "S"):
            if not self.sentence_count == 0:
                newLabel = node.label + str(self.sentence_count)
                node.setLabel(newLabel)
            self.sentence_count = self.sentence_count + 1"""
            
        self.elements[self.indexOf(i,j)].add(node)
    
    def contains(self, label, i, j):
        if(i > j):
            raise Exception("Indice non valido")
        for elementSet in self.elements[self.indexOf(i,j)]:
            if(elementSet.label == label):
                return  True, elementSet
        return False, None
        #return Node(str(label)) in self.get(i,j)
    
    def print(self):
        #print each element in multiset, with his label and children with divisor
        for i in range(self.len):
            for j in range(i, self.len):
                el = self.get(i,j)
                print(f"({i},{j}) : ", end="")
                if(len(el) == 0):
                    print("empty")
                else:
                    for element in el:
                        print(f"{element.label}({element.children}) ", end="")
                    print()
        print("\n--------------------------------------------------\n")

            
            
        #print(self.elements)
        
def contains(nonterminals, table : Table, i, k, j):
    # if table.get(i,k) or table.get(k,j):
    #     print("[in contains] = " + str(table.contains( nonterminals[0].symbol(), i, k) and table.contains( nonterminals[1].symbol(), k+1, j)))
    #     print( nonterminals[0].symbol() + " <=> " + str(table.get(i, k)))
    #     print( nonterminals[1].symbol() + " <=> " + str(table.get(k+1, j)))
    return table.contains( nonterminals[0].symbol(), i, k)[0] and table.contains( nonterminals[1].symbol(), k+1, j)[0]



def printTree(result: Table):
    root_set = result.get(0, result.getLength() - 1)
    i = 0
    for root in root_set:
        if root.label.startswith("S"):
            current_dot = Digraph(comment=f'S_{i}')
            current_dot.attr(rankdir='TB')  
            current_dot.attr('node', shape='circle')

            queue = [root]
            while queue:
                current_node = queue.pop(0)
                current_node_id = str(id(current_node)) 
                current_dot.node(current_node_id, current_node.label)

                if not current_node.isTerminal():
                    for child in current_node.children:
                        child_id = str(id(child))
                        current_dot.node(child_id, child.label)
                        current_dot.edge(current_node_id, child_id)  
                        queue.append(child)
           
            if not os.path.exists("CKY_tree"):
                os.makedirs("CKY_tree")
            current_dot.render(f'tree_{i}.gv', directory='CKY_tree', format='png', cleanup=True)
            i += 1
            print(f"{i} trees printed")


            
            
    
def CKY(words : List[str], grammar: CFG):
    table = Table(len(words))
    
    for j in range(0, len(words)):
        #print("j: " + str(j))
        for production in grammar.productions(rhs=words[j]):
            table.insert(Node(production.lhs().symbol(), Node(words[j])), j, j)
        for i in range(j-1, -1, -1):
            #print("i: " + str(i))
            for k in range(i, j):
                #print("k: " + str(k))
                for production in list(filter(lambda x: x.is_nonlexical() and (contains(x.rhs(), table, i, k, j)), grammar.productions())):
                    table.insert( 
                            Node(production.lhs().symbol(), 
                                table.getElement(production.rhs()[0].symbol(), i, k),
                                table.getElement(production.rhs()[1].symbol(), k+1, j)
                                )
                            , i, j)
    
    return table


# t = Table(5)
# t.insert(Node("B"), 0, 0)
# t.insert(Node("C"), 1, 1)
# t.contains("B")







