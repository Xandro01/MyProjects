
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX fx:   <http://sparql.xyz/facade-x/ns/>
PREFIX pl:   <http://www.semanticweb.org/patric/ontologies/2025/3/Programming_Languages_Ontology#>
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
PREFIX owl:  <http://www.w3.org/2002/07/owl#>
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX schema: <http://schema.org/>


 #1a) Selezionare tutti  i paradigmi presenti nella nostra ontologia ordinati dal nome in ordine alfabetico e per ciascuno conta il numero di linguaggi che lo implementano ( sono in relazione con Paradigm attraverso una object property implements).
   SELECT ?paradigmLabel (COUNT(?programmingLanguage) AS ?languagesCount)
   WHERE {
    ?paradigm a pl:ProgrammingParadigm.
    ?programmingLanguage pl:implements ?paradigm.
    ?paradigm rdfs:label ?paradigmLabel.
    }
   GROUP BY ?paradigmLabel ?languagesCount
   ORDER BY desc(?languagesCount)
   
#2a) viene fornita in input alla query una lista di paradigmi scelti LIST_OF_PARADIGMS (Ad esempio ["EventOrientedParadigm", "FunctionalParadigm"])

#tra quelli mostrati nella query precedente, ora la query è: selezionare per ogni paradigma, la label di tutti i linguaggi che implementano quel paradigma, ordinati per nome del linguaggio in ordine alfabetico. Raggruppa per paradigma.
SELECT DISTINCT ?paradigmLabel ?programmingLanguageLabel 
WHERE {
  ?paradigm a pl:ProgrammingParadigm.
  ?programmingLanguage pl:implements ?paradigm.
  ?programmingLanguage rdfs:label ?programmingLanguageLabel.
  ?paradigm rdfs:label ?paradigmLabel.
  FILTER(?paradigmLabel IN (LIST_OF_PARADIGMS))   
}
  GROUP BY ?paradigmLabel
  ORDER BY ?programmingLanguageLabel

#Versione con group concat
SELECT ?paradigmLabel (GROUP_CONCAT(DISTINCT ?programmingLanguageLabel; separator=", ") AS ?languages)
WHERE {
  ?paradigm a pl:ProgrammingParadigm.
  ?programmingLanguage pl:implements ?paradigm.
  ?programmingLanguage rdfs:label ?programmingLanguageLabel.
  ?paradigm rdfs:label ?paradigmLabel.
  FILTER(?paradigmLabel IN ("EventOrientedParadigm"@en, "ObjectOrientedParadigm"@en))   
}
GROUP BY ?paradigmLabel

#3a) a partiree dal nome PROGRAMMING_LANGUAGE_NAME di un Linguaggio, otteniamo i nomi dei software fatti con quel linguaggio attraverso la proprietà pl:writeIn, che è in relazione con schema:SoftwareApplication e il linguaggio è in relazione con pl:ProgrammingLanguageSet attraverso la proprietà pl:hasMember. 
#a partire da questo facciamo una query federata per ottenere anche le informazioni su quel software da wikidata, ottenendo il logo (wdt:P154), la descrizione (rdfs:description) e la categoria (wdt:P31), il paese (wdt:P17) del software
SELECT ?softwareApplicationLabel ?softwareApplicationDescription ?softwareApplicationLogo ?categoryLabel
WHERE {
  ?programmingLanguage rdfs:label "Java"@en.
  ?programmingLanguageSet pl:hasMember ?programmingLanguage.
  ?softwareApplication pl:writeIn ?programmingLanguageSet.
  ?softwareApplication rdfs:label ?softwareApplicationLabel.
  ?softwareApplication rdfs:description ?softwareApplicationDescription.
  
  
  SERVICE <https://query.wikidata.org/sparql> {
    ?softwareApplicationWikidata rdfs:label ?softwareApplicationLabel .
    FILTER(lang(?softwareApplicationLabel) = "en")
    
    OPTIONAL { ?softwareApplicationWikidata wdt:P154 ?softwareApplicationLogo. }
    OPTIONAL { 
      ?softwareApplicationWikidata wdt:P31 ?category.
      ?category rdfs:label ?categoryLabel.
      FILTER(lang(?categoryLabel) = "en")
    }
    OPTIONAL { 
      ?softwareApplicationWikidata wdt:P17 ?country.
      ?country rdfs:label ?countryLabel.
      FILTER(lang(?countryLabel) = "en")
    }
  }
}

SELECT ?softwareApplicationLabel  ?softwareApplicationLogo (GROUP_CONCAT(DISTINCT ?categoryLabel; separator=", ") AS ?categories)
WHERE {
  ?programmingLanguage rdfs:label "C".
  ?programmingLanguageSet a pl:ProgrammingLanguageSet.
  ?programmingLanguageSet <http://www.ontologydesignpatterns.org/cp/owl/collectionentity.owl#hasMember> ?programmingLanguage.
  ?softwareApplication pl:writeIn ?programmingLanguageSet.
  ?softwareApplication rdfs:label ?softwareApplicationLabel.
 # ?softwareApplication rdfs:comment ?softwareApplicationDescription.

  SERVICE <https://query.wikidata.org/sparql> {
    ?softwareApplicationWikidata rdfs:label ?softwareApplicationLabel.
    ?softwareApplicationWikidata wdt:P31 ?class.
	?class wdt:P279* wd:Q7397.
    
    OPTIONAL { ?softwareApplicationWikidata wdt:P154 ?softwareApplicationLogo. }
    
    OPTIONAL { 
      ?softwareApplicationWikidata wdt:P31 ?category.
      ?category rdfs:label ?categoryLabel.
      FILTER(lang(?categoryLabel) = "en")
    }

    OPTIONAL { 
      ?softwareApplicationWikidata wdt:P17 ?country.
      ?country rdfs:label ?countryLabel.
      FILTER(lang(?countryLabel) = "en")
    }
     ?softwareApplicationWikidata dc:description ?softwareDescription
  }
}
GROUP BY ?softwareApplicationLabel  ?softwareApplicationLogo 
  





#4a) Viene fornita in input una lista di linguaggi scelti, la query è: Selezionare le istanze di pl:DevelopmentEnvironment, che sono in relazione con "pl:ProgrammingLanguageSet" attraverso la object property pl:allowDevelopmentSet, dove uno o più linguaggi nella lista sono istanze of "pl:ProgrammingLanguageSet".
Nella select seleziona anche quali dei linguaggi della lista sono in relazione e raggruppali per developmentEnvironment.
SELECT ?developmentEnvironmentLabel  
WHERE {
  ?programmingLanguage rdfs:label "Java"@en.
  ?developmentEnvironment pl:allowsDevelopmentOf ?programmingLanguageSet.
  ?programmingLanguageSet <http://www.ontologydesignpatterns.org/cp/owl/collectionentity.owl#hasMember> ?programmingLanguage.
  ?programmingLanguage rdfs:label ?programmingLanguageLabel.
  ?developmentEnvironment rdfs:label ?developmentEnvironmentLabel.
  
}

-----------------------------------------------------------------------------------

# 1b) A partire da un nome PROGRAMMING_LANGUAGE_NAME di un linguaggio, Selezionare tutte le informazioni su quel linguaggio, creator (dalla object propety pl:createdBy), label (da rdfs:label), description (da rdfs description), Compilatore (da pl:use), Interprete (da pl:use), Lista paradigmi che implementa (da pl:implements), se è compilato o semi-compilato (lo si capisce è sottoclasse di CompiledProgrammingLanguage o Semi-compiledProgrammingLanguage), la tipizzazione ad esecizopme e a compilazione (dalle data property pl:hasEsecutionTyping e pl:hasCompileTyping) e infine il link del logo presente in pl:hasLogo.
     Restituisci le label degli oggeti quando possibile, altrimenti il valore della data property.
SELECT ?creatorLabel ?description ?compilerLabel ?interpreterLabel (GROUP_CONCAT(DISTINCT ?paradigmLabel; separator=", ") AS ?paradigmLabel) ?isSemiCompiled ?executionTyping ?compileTyping ?logo
WHERE {
    ?programmingLanguage rdfs:label "Perl".
    
    OPTIONAL { 
    ?programmingLanguage rdfs:comment ?description.
    }
    
    OPTIONAL { 
        ?creator a pl:ProgrammingLanguageCreator.
        ?programmingLanguage pl:createdBy ?creator. 
        ?creator rdfs:label ?creatorLabel. 
    }
    
    OPTIONAL { 
        ?compiler a* pl:Compiler.
        ?programmingLanguage pl:use ?compiler. 
        ?compiler rdfs:label ?compilerLabel. 
    }
    
    OPTIONAL { 
        ?interpreter a pl:Interpreter.
        ?programmingLanguage pl:use ?interpreter.
        ?interpreter rdfs:label ?interpreterLabel.  
    }
    
    OPTIONAL { 
        ?programmingLanguage pl:implements ?paradigm. 
        ?paradigm rdfs:label ?paradigmLabel. 
    }
    
    OPTIONAL {
        ?programmingLanguage pl:hasEsecutionTyping ?executionTyping. 
        ?programmingLanguage pl:hasCompileTyping ?compileTyping. 
    }
    
    OPTIONAL { ?programmingLanguage pl:hasLogo ?logo. }
    OPTIONAL { ?programmingLanguage a pl:SemiCompiledProgrammingLanguage. }

    BIND(IF(BOUND(?programmingLanguage) && EXISTS{?programmingLanguage a pl:SemiCompiledProgrammingLanguage}, "Yes", "No") AS ?isSemiCompiled)
}
GROUP BY ?creatorLabel ?description ?compilerLabel ?interpreterLabel ?isSemiCompiled ?executionTyping ?compileTyping ?logo

    
# 2b) A partire dal nome PROGRAMMING_LANGUAGE_NAME di un linguaggio Selezionare il conteggio del numero di schema:SoftwareApplication che hanno una relazione pl:writeIn con
      pl:ProgrammingLanguageSet dove il linguaggio è uno dei linguaggi contenuti, ovvero esiste una proprietà pl:hasMember tra quel linguaggio  e pl:ProgrammingLanguageSet. 
    SELECT (COUNT(?softwareApplication) AS ?applicationCount)
    WHERE {
        ?programmingLanguage rdfs:label "Java"@en.
        ?softwareApplication rdf:type schema:SoftwareApplication.
        ?softwareApplication pl:writeIn ?programmingLanguageSet.
        ?programmingLanguageSet <http://www.ontologydesignpatterns.org/cp/owl/collectionentity.owl#hasMember> ?programmingLanguage.
    }
    
# 3b) A partire da "PROGRAMMING_LANGUAGE_NAME" cerca altri linguaggi simili al linguaggio scelto, ovvero che condividono lo stesso compilatore (pl:use) o lo stesso interprete (pl:use) o (hanno in comune l'object property pl:originatedFrom) oppure hanno la stessa tipologia di compilazione (pl:hasCompileTyping) E (devono essere verificate insieme ) di esecuzione (pl:hasEsecutionTyping).
SELECT DISTINCT ?similarProgrammingLanguageLabel
WHERE {
    ?programmingLanguage a pl:ProgrammingLanguage ;
                         rdfs:label "Java"@en.

    OPTIONAL { ?programmingLanguage pl:use ?refCompiler. }
    OPTIONAL { ?programmingLanguage pl:implements ?refParadigm. }
    OPTIONAL { ?programmingLanguage pl:use ?refInterpreter. }
    OPTIONAL { ?programmingLanguage pl:originatesFrom ?refOrigin. }
    OPTIONAL { ?programmingLanguage pl:hasCompileTyping ?refCompileTyping. }
    OPTIONAL { ?programmingLanguage pl:hasEsecutionTyping ?refExecutionTyping. } 
    
    ?similarProgrammingLanguage a pl:ProgrammingLanguage ;
                                rdfs:label ?similarProgrammingLanguageLabel.

    FILTER(?programmingLanguage != ?similarProgrammingLanguage)

    OPTIONAL { ?similarProgrammingLanguage pl:use ?compiler. }
    OPTIONAL { ?similarProgrammingLanguage pl:implements ?Paradigm. }
    OPTIONAL { ?similarProgrammingLanguage pl:use ?interpreter. }
    OPTIONAL { ?similarProgrammingLanguage pl:originatesFrom ?origin. }
    OPTIONAL { ?similarProgrammingLanguage pl:hasCompileTyping ?compileTyping. }
    OPTIONAL { ?similarProgrammingLanguage pl:hasEsecutionTyping ?executionTyping. }

    FILTER(
        (BOUND(?refCompiler) && BOUND(?compiler) && ?refCompiler = ?compiler) ||
        (BOUND(?refInterpreter) && BOUND(?interpreter) && ?refInterpreter = ?interpreter) ||
        (BOUND(?refParadigm) && BOUND(?paradigm) && ?refParadigm = ?paradigm) ||
        (BOUND(?refOrigin) && BOUND(?origin) && ?refOrigin = ?origin) ||
        (BOUND(?refCompileTyping) && BOUND(?compileTyping) && ?refCompileTyping = ?compileTyping) &&
        (BOUND(?refExecutionTyping) && BOUND(?executionTyping) && ?refExecutionTyping = ?executionTyping)
    )
}


#Query federata integrando informazioni prese da wikidata
# 4b) Query federata integrando informazioni prese da wikidata
# A partire dal nome di un linguaggio "PROGRAMMING_LANGUAGE_NAME" selezionare dalla mia ontologia pl, ricavare il linguaggio da cui deriva attraverso la proprietà "originatesFrom".
# Mentre da wikidata aggiungi altre informazioni storiche come anno di creazione (P571), influenzedBy (P737)
SELECT DISTINCT ?originLabel ?creationYear (GROUP_CONCAT(DISTINCT ?influencedByLabel; separator=", ") AS ?influencedByLabel)
WHERE {
    ?programmingLanguage rdfs:label "Perl".
    
    OPTIONAL {
        ?programmingLanguage pl:originatesFrom ?origin.
        ?origin rdfs:label ?originLabel.
    }
    
    SERVICE <https://query.wikidata.org/sparql> {
        ?programmingLanguageWikidata rdfs:label "Perl"@en .
        ?softwareApplicationWikidata wdt:P31 ?class.
        ?class wdt:P279* wd:Q9143.
        
        OPTIONAL { 
            ?programmingLanguageWikidata wdt:P571 ?creationYear. 
        }
        
        OPTIONAL { 
            ?programmingLanguageWikidata wdt:P737 ?influencedBy. 
            ?influencedBy rdfs:label ?influencedByLabel.
            FILTER(lang(?influencedByLabel) = "en").
            FILTER(STRLEN(STR(?influencedByLabel)) > 0).
        }
    }
}
GROUP BY ?originLabel ?creationYear
HAVING (STRLEN(STR(?influencedByLabel)) > 0)
}

