:- use_module(library(uuid)).
new_uuid(UUID) :- uuid(UUID).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord; 
% in particolare, l'azione è applicabile se:
% - la cella a nord della posizione corrente non è una cella di tipo wall.
applicable(nord, pos(monster_position, R, C)) :-
    R > 0,
    R1 is R - 1,
    \+ pos(wall, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est;
% in particolare, l'azione è applicabile se:
% - la cella a est della posizione corrente non è una cella di tipo wall.
applicable(est, pos(monster_position, R, C)) :-
    size(_, Col),
    C < Col,
    C1 is C + 1,
    \+ pos(wall, R, C1).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud;
% in particolare, l'azione è applicabile se:
% - la cella a sud della posizione corrente non è una cella di tipo wall.
applicable(sud, pos(monster_position, R, C)) :-
    size(Row, _),
    R < Row,
    R1 is R + 1,
    \+ pos(wall, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest;
% in particolare, l'azione è applicabile se:
% - la cella a ovest della posizione corrente non è una cella di tipo wall.
applicable(ovest, pos(monster_position, R,C)) :-
    C > 0,
    C1 is C - 1,
    \+ pos(wall, R, C1).

% Predicato che consente di verificare se la posizione corrente è già stata visitata (presente in Visited).
check_visited(_, visited(pos(monster_position, R, C), _, _, _), Visited) :- 
    \+ member(visited(pos(monster_position, R, C),  _, _, _ ), Visited).

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso nord di una cella.
transform(nord, pos(T, R, C), Result) :- 
    R1 is R - 1,
    Result = pos(T, R1, C), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso sud di una cellla.
transform(sud, pos(T, R, C), Result) :- 
    R1 is R + 1,
    Result = pos(T, R1, C), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso est di una cella.
transform(est, pos(T, R, C), Result) :- 
    C1 is C + 1,
    Result = pos(T, R, C1), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso ovest di una cella.
transform(ovest, pos(T, R, C), Result) :- 
    C1 is C - 1,
    Result = pos(T, R, C1), !.

% Predicato che consente di inizializzare la strategia di controllo A*, richiamato da python per iniziare la ricerca del cammino.
% I parametri sono:
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
% Come euristica viene utilizzata la distanza di Manhattan tra la posizione corrente del mostro e il portale.
% Gli stati sono rappresentati dal predicato state(pos(monster_position, R, C), StateActionParent, NodeIdentifier, ParentIdentifier, Cost) dove:
% - pos(monster_position, R, C) rappresenta la posizione corrente del mostro
% - StateActionParent rappresenta l'azione che ha portato allo stato corrente a partire dallo stato padre
% - NodeIdentifier rappresenta un identificativo univoco per lo stato corrente
% - ParentIdentifier rappresenta l'identificativo dello stato padre
ricerca_a_star(Cammino, FinalVisited):-
    pos(monster_position, R, C),
    pos(portal, R1, C1),
    manhattan_distance((R, R1), (C, C1), Cost),
    ampiezza_search([state(pos(monster_position, R, C), nothing, 0, -1, Cost)], [], Cammino, FinalVisitedPosition),
    extract_state_from_visited(FinalVisitedPosition, FinalVisited),
    nl, write('walk: '), print(Cammino), nl, nl.

extract_state_from_visited([], []).     

% Predicato che consente di estrarre la posizione dallo stato visitato a partitre dal predicato Visited, 
% ad ogni passo lo stato è rappresentato da una lista che contiene la posizione del mostro
extract_state_from_visited([visited(State, _, _, _) | Tail], [State | TailState]):-
    extract_state_from_visited(Tail, TailState).

% Predicato che rappresenta il caso base della ricerca in ampiezza. 
% Questo caso si verifica quando la posizione corrente del mostro è uguale alla posizione del portale
% generate_action_path consente di generare il cammino a partire dall'ultimo predicato visited
ampiezza_search([state(pos(monster_position, R, C), StateAction, Name, Parent, _) | _], Visited, Cammino, FinalVisited):- 
    pos(portal, R, C),
    generate_action_path(visited(pos(monster_position, R, C), Name, Parent, StateAction), Visited, Path, FinalVisited),
    Cammino = Path, !.

% Predicato che consente di effettuare la ricerca in ampiezza. I parametri sono:
% - [state(pos(monster_position, MonsterRow, MonsterCol), StateAction, Name, Parent, Cost) | TailToVisit]: lista degli stati frontiera da visitare.
% - Visited: lista dei predicati visited raggiunti durante la ricerca
% avranno come identificativo l'identificativo dello stato corrente.
% Questo predicato riguarda il caso in cui lo stato corrente non è presente nella lista dei visitati.
ampiezza_search([state(pos(monster_position, MonsterRow, MonsterCol), StateAction, Name, Parent, Cost) | TailToVisit], Visited, Cammino, FinalVisited):-
    check_visited(_, visited(pos(monster_position, MonsterRow, MonsterCol), Name, Parent, StateAction ), Visited),
    findall(
        Az,
        applicable(Az, pos(monster_position, MonsterRow, MonsterCol)),
        ActionsList
    ),
    new_uuid(UUID),
    genera_transform(state(pos(monster_position, MonsterRow, MonsterCol), StateAction, Name, Parent, Cost), ActionsList, NewState, Visited, UUID),
    difference(NewState, TailToVisit, StateToAdd),
    append(TailToVisit, StateToAdd, NewTailToVisit),
    sort_by_euristic(NewTailToVisit, NewTailToVisitSorted),
    ampiezza_search(NewTailToVisitSorted, [visited(pos(monster_position, MonsterRow, MonsterCol), Name, Parent, StateAction) | Visited], Cammino, FinalVisited).

% Predicato che consente di effettuare la ricerca in ampiezza. I parametri sono:
% - [state(pos(monster_position, R, C), _, Name, Parent, _) | TailToVisit]: lista degli stati frontiera da visitare.
% - Visited: lista dei predicati visited raggiunti durante la ricerca
% Questo predicato riguarda il caso in cui lo stato corrente è già presente nella lista dei visitati, pertanto non lo consideriamo.
ampiezza_search([state(pos(monster_position, R, C), _, Name, Parent, _) | TailToVisit], Visited, Cammino, FinalVisited):- 
    \+ check_visited(_, visited(pos(monster_position, R, C), Name, Parent), Visited),
    ampiezza_search(TailToVisit, Visited, Cammino, FinalVisited).

genera_transform(_, [], [], _, _).

% Consente di generare gli stati successori a partire dallo stato corrente. Per ogni azione applicabile allo stato corrente, viene generato uno stato successore.
% Al primo stato successore viene assegnato un identificativo univoco, in modo da poterlo distinguere dagli altri stati. 
% Gli stati successori generati a partire dallo stato corrente
genera_transform(state(pos(monster_position, MonsterRow, MonsterCol), StateAction, ParentName, P, PCost), [HeadAction | TailAction], [state(pos(monster_position, Row, Col), HeadAction, Length, ParentName, Cost) | Tail], Visited, Length):-
    transform(HeadAction, pos(monster_position, MonsterRow, MonsterCol), pos(monster_position, Row, Col)),
    new_uuid(UUID),
    pos(portal, R1, C1),
    manhattan_distance((Row, R1), (Col, C1), DCost),
    Cost is PCost + DCost,
    genera_transform(state(pos(monster_position, MonsterRow, MonsterCol), StateAction, ParentName, P, PCost), TailAction, Tail, Visited, UUID).

difference([], _, []).

% Predicato che consente di implementare la differenza insiemistica tra due liste, 
%consentendo di rimuovere gli elementi duplicati.
difference([S | Tail], B, Risultato):-
    member(S, B), !,
    difference(Tail, B, Risultato).

difference([S | Tail], B, [S | RisTail]):-
    difference(Tail, B, RisTail).

manhattan_distance((X1, Y1), (X2, Y2), Distance) :-
    abs(X1 - X2, Dx),
    abs(Y1 - Y2, Dy),
    Distance is Dx + Dy.

% Predicato che consente di generare il cammino a partire dall'ultimo predicato visited, in particolare,
% il cammino è generato a partire dall'ultimo predicato visited fino al predicato visited iniziale.
% I parametri sono:
% - visited(pos(monster_position, R, C), Name, Parent, StateAction): predicato visited corrente
% - [visited(_, N, _, _) | Tail]: lista dei predicati visited
% - Path: Contiene il cammino di azioni ricostruito a partire dall'ultimo predicato visited fino al predicato visited iniziale
% - Visited: Contiene la lista dei predicati visitati durante la ricerca
% Questo è il caso in cui il predicato visited corrente che stiamo analizzando ha come padre lo stato visited
% preso in considerazione nella lista dei predicati visited.
% In questo caso, l'azione presente nel primo parametro (rappresentante il visisted corrente viene aggiunto a Path 
% e il predicato visited corrente viene aggiunto alla lista degli stati visitati durante la ricerca e si passa al predicato visited successivo.
generate_action_path(visited(pos(monster_position, R, C), Name, Parent, StateAction), [visited(Pos, N, PN, PAction) | Tail], [StateAction | TPath], [visited(pos(monster_position, R, C), Name, Parent, StateAction) | TailVisited]) :-
    Parent = N,
    generate_action_path(visited(Pos, N, PN, PAction), Tail, TPath, TailVisited).

% Predicato che consente di generare il cammino a partire dall'ultimo predicato visited, in particolare, 
% il cammino è generato a partire dall'ultimo predicato visited fino al predicato visited iniziale.
% I parametri sono:
% - visited(pos(monster_position, R, C), Name, Parent, StateAction): predicato visited corrente
% - [visited(_, N, _, _) | Tail]: lista dei predicati visited
% - Path: Contiene il cammino di azioni ricostruito a partire dall'ultimo predicato visited fino al predicato visited iniziale
% - Visited: Contiene la lista dei predicati visitati durante la ricerca
% Questo è il caso in cui il predicato visited corrente che stiamo analizzando non ha come padre lo stato visited 
% preso in considerazione nella lista dei predicati visited.
% In questo caso, il predicato visited corrente viene ignorato senza aggiungere nulla a Path e Visited.
generate_action_path(visited(pos(monster_position, R, C), Name, Parent, StateAction), [visited(_, N, _, _) | Tail], Path, Visited) :-
    Parent \= N,
    generate_action_path(visited(pos(monster_position, R, C), Name, Parent, StateAction), Tail, Path, Visited).

% Caso base della ricorsione, in questo caso il predicato visited corrente è il visited iniziale.
generate_action_path(visited(pos(monster_position, R, C), Name, -1, StateAction), [], [StateAction], [visited(pos(monster_position, R, C), Name, -1, StateAction)]) :- true.

transform_to_key_value_euristic([], []) :- true.

transform_to_key_value_euristic([state(pos(monster_position, R, C), StateAction, Name, Parent, Cost) | Rest], [Cost-state(pos(monster_position, R, C), StateAction, Name, Parent, Cost) | RestPairs]) :-
    transform_to_key_value_euristic(Rest, RestPairs).

sort_by_euristic(List, SortedList) :-
    transform_to_key_value_euristic(List, KeyValuePairs),
    keysort(KeyValuePairs, SortedKeyValuePairs),
    extract_state_values(SortedKeyValuePairs, SortedList).

extract_state_values([], []).

extract_state_values([_-State | RestPairs], [State | RestValues]) :-
    extract_state_values(RestPairs, RestValues).
