:- use_module(library(uuid)).
new_uuid(UUID) :- uuid(UUID).

:-[applicable].
:-[transform].
:-[utility].

% Predicato che consente di inizializzare la strategia di controllo A*, richiamato da python per iniziare la ricerca del cammino.
% I parametri sono:
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
% Come euristica viene utilizzata la distanza di Manhattan tra la posizione corrente del mostro e il portale.
% Gli stati sono rappresentati dal predicato state([pos(monster_position, R, C) | Lpos], StateActionParent, HammerTaked, FreeCells, NodeIdentifier, ParentIdentifier, Cost), dove:
% - pos(monster_position, R, C) | Lpos rappresenta la posizione corrente del mostro e delle gemme
% - HammerTaked rappresenta il numero di martelli che si possiede 
% - FreeCells rappresenta le celle libere nello stato corrente
% - StateActionParent rappresenta l'azione che ha portato allo stato corrente a partire dallo stato padre
% - NodeIdentifier rappresenta un identificativo univoco per lo stato corrente
% - ParentIdentifier rappresenta l'identificativo dello stato padre
ricerca_a_star(Cammino, FinalVisited):-
    pos(monster_position, R, C),
    findall(pos(gem, RG, CG), pos(gem, RG, CG), Lpos),
    has_hammer(HammerTaked),
    pos(portal, R1, C1),
    manhattan_distance((R, R1), (C, C1), Cost),
    ampiezza_search([state([pos(monster_position, R, C) | Lpos], nothing, HammerTaked, [], 0, -1, Cost)], [], _, Cammino, FinalVisitedPosition, _),
    extract_state_from_visited(FinalVisitedPosition, FinalVisited),
    nl, write('walk: '), print(Cammino), nl, nl.
   
extract_state_from_visited([], []).  

extract_state_from_visited([visited(State, _, _, _) | Tail], [State | TailState]):-
    extract_state_from_visited(Tail, TailState).

% Predicato che rappresenta il caso base della ricerca in ampiezza. 
% Questo caso si verifica quando la posizione corrente del mostro è uguale alla posizione del portale
% generate_action_path consente di generare il cammino a partire dall'ultimo predicato visited
ampiezza_search([state([pos(monster_position, R, C) | GS], StateAction, HammerTaked, FreeCells, Name, Parent, _) | _], Visited, HammerTaked1, Cammino, FinalVisited, FreeCellsFinal):- 
    pos(portal, R, C), HammerTaked1 is HammerTaked, FreeCellsFinal = FreeCells, 
    generate_action_path( visited([pos(monster_position, R, C) | GS], Name, Parent, StateAction), Visited, Path, FinalVisited),
    Cammino = Path, !.

% Predicato che consente di effettuare la ricerca in ampiezza.
% I parametri sono:
% - [state([pos(monster_position, R, C) | GS], StateAction, HammerTaked, FreeCells, Name, Parent, Cost) | TailToVisit]: lista degli stati da visitare
% - Visited: lista degli stati già visitati
% - HammerTaked1: numero di martelli posseduti alla fine della ricerca, una volta raggiunto il portale
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
% - FreeCellsFinal: lista delle celle libere nello stato finale
% Questo predicato riguarda il caso in cui lo stato corrente non è presente nella lista dei visitati.
ampiezza_search([state([pos(monster_position, MonsterRow, MonsterCol) | GemState], StateAction, HammerTaked, FreeCells, Name, Parent, Cost) | TailToVisit], Visited, HammerTaked1, Cammino, FinalVisited, FreeCellsFinal):-
    check_visited(_, visited([pos(monster_position, MonsterRow, MonsterCol) | GemState], Name, Parent, StateAction ), Visited),
    findall(
        Az,
        applicable(
            Az, 
            pos(monster_position, MonsterRow, MonsterCol),
            [pos(monster_position, MonsterRow, MonsterCol) | GemState],
            HammerTaked,
            FreeCells
        ),
        ActionsList
    ),
    new_uuid(UUID),
    genera_transform(state([pos(monster_position, MonsterRow, MonsterCol) | GemState], StateAction, HammerTaked, FreeCells, Name, Parent, Cost), ActionsList, NewState, Visited, UUID),
    difference(NewState, TailToVisit, StateToAdd),
    append(TailToVisit, StateToAdd, NewTailToVisit),
    sort_by_euristic(NewTailToVisit, NewTailToVisitSorted),
    sort_by_column(GemState, SortTransformedPositionGemColumn),
    sort_by_row(SortTransformedPositionGemColumn, SortTransformedPositionGem),
    ampiezza_search(NewTailToVisitSorted, [ visited([pos(monster_position, MonsterRow, MonsterCol) | SortTransformedPositionGem], Name, Parent, StateAction ) | Visited], HammerTaked1, Cammino, FinalVisited, FreeCellsFinal).

% Predicato che consente di effettuare la ricerca in ampiezza. I parametri sono:
% - [state(pos(monster_position, R, C), _, Name, Parent, _) | TailToVisit]: lista degli stati frontiera da visitare.
% - Visited: lista dei predicati visited raggiunti durante la ricerca
% Questo predicato riguarda il caso in cui lo stato corrente è già presente nella lista dei visitati, pertanto non lo consideriamo.
ampiezza_search([state([pos(monster_position, R, C) | GS], _, _, _, Name, Parent, _) | TailToVisit], Visited, HammerTaked1, Cammino, FinalVisited, FreeCellsFinal):- 
    \+ check_visited(_, visited([pos(monster_position, R, C) | GS], Name, Parent), Visited),
    ampiezza_search(TailToVisit, Visited, HammerTaked1, Cammino, FinalVisited, FreeCellsFinal).

extract_first_element([Head | _], Head).

genera_transform(_, [], [], _, _).

% Consente di generare gli stati successori a partire dallo stato corrente. Per ogni azione applicabile allo stato corrente, viene generato uno stato successore.
% Al primo stato successore viene assegnato un identificativo univoco, in modo da poterlo distinguere dagli altri stati. 
% Gli stati successori generati a partire dallo stato corrente
% Viene utilizzato il predicato init_transform per ottenere lo stato successore a partire dallo stato corrente e
% dall'azione applicabile e tutte le informazioni di stato che vengono modificate, 
% come la posizione del mostro, le gemme, il martello, le celle libere.
genera_transform(state(HeadState, StateAction, HammerTaked, FreeCells, ParentName, P, PCost), [HeadAction | TailAction], [state([pos(monster_position, Row, Col)  | TransformedPositionGem], HeadAction, HammerTaked1, NewFreeCells, Length, ParentName, Cost) | Tail], Visited, Length):-
    init_transform(HeadAction, HeadState, Visited, [pos(monster_position, Row, Col) | TransformedPositionGem], HammerTaked, HammerTaked1, FreeCells, NewFreeCells),
    new_uuid(UUID),
    pos(portal, R1, C1),
    manhattan_distance((Row, R1), (Col, C1), DCost),
    Cost is PCost + DCost,
    genera_transform(state(HeadState, StateAction, HammerTaked, FreeCells, ParentName, P, PCost), TailAction, Tail, Visited, UUID ).

difference([], _, []).

difference([S | Tail], B, Risultato):-
    member(S, B), !,
    difference(Tail, B, Risultato).

difference([S | Tail], B, [S | RisTail]):-
    difference(Tail, B, RisTail).

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso nord.
% I parametri sono:
% - nord: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso nord
% - HammerTaked: numero di martelli posseduti prima dello spostamento
% - HammerTaked1: numero di martelli posseduti dopo lo spostamento
% - FreeCells: lista delle celle libere prima dello spostamento
% - NewFreeCells: lista delle celle libere dopo lo spostamento
% utilizziamo il predicato sort_by_row per ordinare le posizioni delle gemme per riga al fine di garantire il corretto ordine di applicazione delle transformazioni
% utilizziamo il predicato move_monster_position_to_front per spostare la posizione del mostro in prima posizione
% utilizziamo il cut per avere la  mutua esclusione tra le regole e migliorare le prestazioni
init_transform(nord, [pos(monster_position, R, C)| Tail], _, Result, HammerTaked, HammerTaked1, FreeCells, NewFreeCells) :-     
    sort_by_row([pos(monster_position, R, C)| Tail], State),
    transform(nord, State, ResultTMP, [pos(monster_position, R, C)| Tail], HammerTaked, HammerTaked1,  FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result),!.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso sud.
% I parametri sono:
% - sud: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso sud
% - HammerTaked: numero di martelli posseduti prima dello spostamento
% - HammerTaked1: numero di martelli posseduti dopo lo spostamento
% - FreeCells: lista delle celle libere prima dello spostamento
% - NewFreeCells: lista delle celle libere dopo lo spostamento
% utilizziamo il predicato sort_by_row per ordinare le posizioni delle gemme per riga al fine di garantire il corretto ordine di applicazione delle transformazioni
% utilizziamo il predicato move_monster_position_to_front per spostare la posizione del mostro in prima posizione
% utilizziamo il cut per avere la  mutua esclusione tra le regole e migliorare le prestazioni
init_transform(sud, [pos(monster_position, R, C)| Tail], _, Result, HammerTaked, HammerTaked1,  FreeCells, NewFreeCells) :- 
    sort_by_row([pos(monster_position, R, C)| Tail], State),
    reverse(State, ReverseState),
    transform(sud, ReverseState, ResultTMP, [pos(monster_position, R, C)| Tail], HammerTaked, HammerTaked1, FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result),!.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso ovest.
% I parametri sono:
% - ovest: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso ovest
% - HammerTaked: numero di martelli posseduti prima dello spostamento
% - HammerTaked1: numero di martelli posseduti dopo lo spostamento
% - FreeCells: lista delle celle libere prima dello spostamento
% - NewFreeCells: lista delle celle libere dopo lo spostamento
% utilizziamo il predicato sort_by_column per ordinare le posizioni delle gemme per colonna al fine di garantire il corretto ordine di applicazione delle transformazioni
% utilizziamo il predicato move_monster_position_to_front per spostare la posizione del mostro in prima posizione
% utilizziamo il cut per avere la  mutua esclusione tra le regole e migliorare le prestazioni
init_transform(ovest, [pos(monster_position, R, C)| Tail], _, Result, HammerTaked, HammerTaked1,  FreeCells, NewFreeCells) :- 
    sort_by_column([pos(monster_position, R, C)| Tail], State),
    transform(ovest, State, ResultTMP, [pos(monster_position, R, C)| Tail], HammerTaked, HammerTaked1,  FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso est.
% I parametri sono:
% - est: direzione verso cui spostare il mostro
% - [pos(monster_position, R, C)| Tail]: lista delle posizioni delle gemme
% - Visited: lista delle posizioni già visitate durante il passo corrente
% - Result: lista delle posizioni delle gemme dopo lo spostamento del mostro, con il mostro spostato verso est
% - HammerTaked: numero di martelli posseduti prima dello spostamento
% - HammerTaked1: numero di martelli posseduti dopo lo spostamento
% - FreeCells: lista delle celle libere prima dello spostamento
% - NewFreeCells: lista delle celle libere dopo lo spostamento
% utilizziamo il predicato sort_by_column per ordinare le posizioni delle gemme per colonna al fine di garantire il corretto ordine di applicazione delle transformazioni
% utilizziamo il predicato move_monster_position_to_front per spostare la posizione del mostro in prima posizione
% utilizziamo il cut per avere la  mutua esclusione tra le regole e migliorare le prestazioni
init_transform(est, [pos(monster_position, R, C)| Tail], _, Result, HammerTaked, HammerTaked1,  FreeCells, NewFreeCells) :- 
    sort_by_column([pos(monster_position, R, C)| Tail], State),
    reverse(State, ReverseState),  
    transform(est, ReverseState, ResultTMP, [pos(monster_position, R, C) | Tail], HammerTaked, HammerTaked1,  FreeCells, NewFreeCells),
    move_monster_position_to_front(ResultTMP, Result), !.

init_transform(est, [pos(monster_position, _, _)| _], _, _, _, _,  _, _).

check_visited(_, visited([pos(monster_position, R, C) | GemState], _, _, _), Visited) :- 
    sort_by_column(GemState, SortTransformedPositionGemColumn),
    sort_by_row(SortTransformedPositionGemColumn, SortTransformedPositionGem),
    \+ member(visited([pos(monster_position, R, C) | SortTransformedPositionGem],  _, _, _ ), Visited).

extract_state_values([], []).

extract_state_values([_-State | RestPairs], [State | RestValues]) :-
    extract_state_values(RestPairs, RestValues).

abs(X, Y) :- X >= 0, Y is X.

abs(X, Y) :- X < 0, Y is -X.

manhattan_distance((X1, Y1), (X2, Y2), Distance) :-
    abs(X1 - X2, Dx),
    abs(Y1 - Y2, Dy),
    Distance is Dx + Dy.

transform_to_key_value_euristic([], []) :- true.

transform_to_key_value_euristic([state([pos(monster_position, R, C) | GemState], StateAction, HammerTaked, FreeCells, Name, Parent, Cost) | Rest], [Cost-state([pos(monster_position, R, C) | GemState], StateAction, HammerTaked, FreeCells, Name, Parent, Cost) | RestPairs]) :-
    transform_to_key_value_euristic(Rest, RestPairs).

sort_by_euristic(List, SortedList) :-
    transform_to_key_value_euristic(List, KeyValuePairs),
    keysort(KeyValuePairs, SortedKeyValuePairs),
    extract_state_values(SortedKeyValuePairs, SortedList).

generate_action_path(visited([pos(monster_position, R, C) | GS], Name, Parent, StateAction ), [visited(Pos, N, PN, PAction) | Tail], [StateAction | TPath], [visited([pos(monster_position, R, C) | GS], Name, Parent, StateAction ) | TailVisited]) :-
    Parent = N,
    generate_action_path(visited(Pos, N, PN, PAction), Tail, TPath, TailVisited).

generate_action_path(visited([pos(monster_position, R, C) | GS], Name, Parent, StateAction), [visited(_, N, _, _) | Tail], Path, Visited) :-
    Parent \= N,
    generate_action_path(visited([pos(monster_position, R, C) | GS], Name, Parent, StateAction), Tail, Path, Visited).

generate_action_path(visited([pos(monster_position, R, C) | GS], Name, -1, StateAction), [], [StateAction], [visited([pos(monster_position, R, C) | GS], Name, -1, StateAction )]) :- true.