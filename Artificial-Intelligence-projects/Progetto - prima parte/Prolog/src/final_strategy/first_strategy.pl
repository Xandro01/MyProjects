:-[applicable].
:-[transform].
:-[utility].

% Predicato che consente di inizializzare la strategia di controllo iterative deepening. 
% Viene richiamato da python per iniziare la ricerca del cammino.
% I parametri sono:
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
ricerca_iterative_deepening(Cammino, FinalVisited):-
    pos(monster_position, R, C),
    findall(pos(gem, RG, CG), pos(gem, RG, CG), Lpos),
    has_hammer(HammerTaked),
    iterative_deepening_search(1, [[pos(monster_position, R, C) | Lpos]], pos(monster_position, R, C), Lpos, HammerTaked, _, Cammino, FinalVisited, _),
    write('walk: '), print(Cammino), nl.


% Predicato che consente di effettuare la ricerca del cammino tramite iterative deepening. 
% Serve per catturare il caso in cui la profondity search abbia successo.
% I parametri sono:
% - Limit: profondità massima della ricerca
% - Visited: lista delle posizioni già visitate durante l'i-esima iterazione
% - pos(monster_position, R, C): posizione iniziale del mostro
% - Lpos: lista delle posizioni delle gemme
% - HammerTaked: numero di martelli nello statocorrente
% - HammerTaked1: numero di martelli dopo la ricerca
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
iterative_deepening_search(Limit, Visited, pos(monster_position, R, C), Lpos, HammerTaked, HammerTaked1, Cammino, FinalVisited, FreeCellsFinal):-
    profondity_search(Limit, pos(monster_position, R, C), Lpos, Cammino, Visited, FinalVisited, HammerTaked, HammerTaked1, [], FreeCellsFinal).

% Predicato che consente di effettuare la ricerca del cammino tramite iterative deepening. 
% Serve per catturare il caso in cui la profondity search non abbia successo.
% I parametri sono:
% - Limit: profondità massima della ricerca
% - Visited: lista delle posizioni già visitate durante l'i-esima iterazione
% - pos(monster_position, R, C): posizione iniziale del mostro
% - Lpos: lista delle posizioni delle gemme
% - HammerTaked: numero di martelli nello statocorrente
% - HammerTaked1: numero di martelli dopo la ricerca
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
% - FreeCellsFinal: lista delle celle libere dopo la ricerca
iterative_deepening_search(Limit, Visited, pos(monster_position, R, C), Lpos, HammerTaked, HammerTaked1, Cammino, FinalVisited, FreeCellsFinal):-
    \+ profondity_search(Limit, pos(monster_position, R, C), Lpos, Cammino, Visited, FinalVisited, HammerTaked, HammerTaked1, [], FreeCellsFinal),
    NewLimit is Limit + 1,
    iterative_deepening_search(NewLimit, Visited, pos(monster_position, R, C), Lpos, HammerTaked, HammerTaked1, Cammino, FinalVisited, FreeCellsFinal).

% Predicato che rappresenta il caso base della ricerca in profondità. 
% In particolare, la ricerca termina quando la posizione del mostro coincide con quella del portale.
profondity_search(_, pos(monster_position, MonsterRow, MonsterCol), _, [], Visited, FinalVisited,HammerTaked, HammerTaked1, FreeCells, FreeCellsFinal) :- pos(portal, MonsterRow, MonsterCol), HammerTaked1 is HammerTaked, FreeCellsFinal = FreeCells, FinalVisited = Visited, !.

% Predicato che consente di effettuare la ricerca del cammino tramite profondity search.
% I parametri sono:
% - Limit: profondità massima della ricerca
% - pos(monster_position, R, C): posizione iniziale del mostro
% - Lpos: lista delle posizioni delle gemme
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
% - Visited: lista delle posizioni già visitate durante l'i-esima iterazione
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
% - HammerTaked: numero di martelli nello statocorrente
% - HammerTaked1: numero di martelli dopo la ricerca
% - FreeCells: lista delle celle libere
% - FreeCellsFinal: lista delle celle libere dopo la ricerca
profondity_search(Limit, pos(monster_position, MonsterRow, MonsterCol), GemState, [Az|SeqAzioni], Visited, FinalVisited, HammerTaked, HammerTaked1, FreeCells, FreeCellsFinal) :-
    Limit > 0,
    applicable(
        Az, 
        pos(monster_position, MonsterRow, MonsterCol),
        [pos(monster_position, MonsterRow, MonsterCol) | GemState],
        HammerTaked,
        FreeCells
    ),
    init_transform(Az, [pos(monster_position, MonsterRow, MonsterCol) | GemState], Visited, [TransformedPositionMonster | TransformedPositionGem], HammerTaked, NewHammerTaked1, FreeCells, NewFreeCells),
    sort_by_column(TransformedPositionGem, SortTransformedPositionGemColumn),
    sort_by_column(SortTransformedPositionGemColumn, SortTransformedPositionGem),
    NewLimit is Limit - 1,
    profondity_search(NewLimit, TransformedPositionMonster, TransformedPositionGem, SeqAzioni, [[TransformedPositionMonster | SortTransformedPositionGem] | Visited],  FinalVisited, NewHammerTaked1, HammerTaked1, NewFreeCells, FreeCellsFinal).

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso nord.
% I parametri sono:
% - nord: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso nord
% utilizziamo il predicato sort_by_row per ordinare le posizioni delle gemme per riga al fine di garantire il corretto ordine di applicazione delle transformazioni
% utilizziamo il predicato move_monster_position_to_front per spostare la posizione del mostro in prima posizione
% utilizziamo il cut per avere la  mutua esclusione tra le regole e migliorare le prestazioni
init_transform(nord, [pos(monster_position, R, C)| Tail], Visited, Result, HammerTaked, HammerTaked1, FreeCells, NewFreeCells) :-     
    sort_by_row([pos(monster_position, R, C)| Tail], State),
    transform(nord, State, ResultTMP, [pos(monster_position, R, C)| Tail], HammerTaked, HammerTaked1,  FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result),
    check_visited(nord, Result, Visited), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso sud.
% I parametri sono:
% - sud: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso sud
% utilizziamo il predicato sort_by_row per ordinare le posizioni delle gemme per riga al fine di garantire il corretto ordine di applicazione delle transformazioni
% utilizziamo il predicato move_monster_position_to_front per spostare la posizione del mostro in prima posizione
% utilizziamo il cut per avere la  mutua esclusione tra le regole e migliorare le prestazioni
init_transform(sud, [pos(monster_position, R, C)| Tail], Visited, Result, HammerTaked, HammerTaked1,  FreeCells, NewFreeCells) :- 
    sort_by_row([pos(monster_position, R, C)| Tail], State),
    reverse(State, ReverseState),
    transform(sud, ReverseState, ResultTMP, [pos(monster_position, R, C)| Tail], HammerTaked, HammerTaked1,  FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result),
    check_visited(sud, Result, Visited), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso ovest.
% I parametri sono:
% - ovest: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso ovest
% utilizziamo il predicato sort_by_column per ordinare le posizioni delle gemme per colonna al fine di garantire il corretto ordine di applicazione delle transformazioni
init_transform(ovest, [pos(monster_position, R, C)| Tail], Visited, Result, HammerTaked, HammerTaked1,  FreeCells, NewFreeCells) :- 
    sort_by_column([pos(monster_position, R, C)| Tail], State),
    transform(ovest, State, ResultTMP, [pos(monster_position, R, C)| Tail], HammerTaked, HammerTaked1,  FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result),
    check_visited(ovest, Result, Visited), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso est.
% I parametri sono:
% - est: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso est
% utilizziamo il predicato sort_by_column per ordinare le posizioni delle gemme per colonna al fine di garantire il corretto ordine di applicazione delle transformazioni
init_transform(est, [pos(monster_position, R, C)| Tail], Visited, Result, HammerTaked, HammerTaked1,  FreeCells, NewFreeCells) :- 
    sort_by_column([pos(monster_position, R, C)| Tail], State),
    reverse(State, ReverseState),  
    transform(est, ReverseState, ResultTMP, [pos(monster_position, R, C)| Tail], HammerTaked, HammerTaked1,  FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result),
    check_visited(est, Result, Visited), !.

% Predicato che consente di verificare se la lista contenente la posizione corrente del mostriciattolo e delle gemme è già stata visitata (presente in Visited).
check_visited(_, [pos(monster_position, R, C) | GenState], Visited) :- 
    sort_by_column(GenState, SortTransformedPositionGemColumn ),
    sort_by_column(SortTransformedPositionGemColumn, SortTransformedPositionGem ),
    \+ member([pos(monster_position, R, C) | SortTransformedPositionGem], Visited).