
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

% Predicato che consente di inizializzare la strategia di controllo iterative deepening. 
% Viene richiamato da python per iniziare la ricerca del cammino.
% I parametri sono:
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
ricerca_iterative_deepening(Cammino, FinalVisited):-
    pos(monster_position, R, C),
    iterative_deepening_search(1, [pos(monster_position, R, C)], pos(monster_position, R, C), Cammino, FinalVisited),
    write('position visited by monster: '), print(FinalVisited), nl,
    write('walk: '), print(Cammino), nl.

% Predicato che consente di effettuare la ricerca del cammino tramite iterative deepening. Serve per catturare il caso in cui la profondity search abbia successo.
% I parametri sono:
% - Limit: profondità massima della ricerca
% - Visited: lista delle posizioni già visitate durante l'i-esima iterazione
% - pos(monster_position, R, C): posizione iniziale del mostro
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
iterative_deepening_search(Limit, Visited, pos(monster_position, R, C), Cammino, FinalVisited):-
    profondity_search(Limit, pos(monster_position, R, C), Cammino, Visited,  FinalVisited).

% Predicato che consente di effettuare la ricerca del cammino tramite iterative deepening. Serve per catturare il caso in cui la profondity search non abbia successo.
% I parametri sono:
% - Limit: profondità massima della ricerca, viene incrementato ad ogni iterazione
% - Visited: lista delle posizioni già visitate durante l'i-esima iterazione
% - pos(monster_position, R, C): posizione iniziale del mostro
% - Cammino: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale
iterative_deepening_search(Limit, Visited, pos(monster_position, R, C), Cammino, FinalVisited):-
    \+ profondity_search(Limit, pos(monster_position, R, C), Cammino, Visited, FinalVisited),
    NewLimit is Limit + 1,
    iterative_deepening_search(NewLimit, Visited, pos(monster_position, R, C), Cammino,  FinalVisited).

% Predicato che rappresenta il caso base della ricerca in profondità. 
% In particolare, la ricerca termina quando la posizione del mostro coincide con quella del portale.
profondity_search(_, pos(monster_position, MonsterRow, MonsterCol), [], Visited, FinalVisited) :- pos(portal, MonsterRow, MonsterCol), FinalVisited = Visited, !.

% Predicato che consente di effettuare la ricerca in profondità.
% I parametri sono:
% - Limit: profondità massima della ricerca
% - pos(monster_position, MonsterRow, MonsterCol): posizione corrente del mostro
% - [Az|SeqAzioni]: lista delle azioni espresse in termini di nord, sud, ovest, est da compiere per raggiungere un portale,
%   Az è un azione che viene istanziata durante il passo corrente, grazie al predicato applicable
% - Visited: lista delle posizioni già visitate durante l'i-esima iterazione
% - FinalVisited: lista delle posizioni visitate durante l'intera ricerca
profondity_search(Limit, pos(monster_position, MonsterRow, MonsterCol), [Az|SeqAzioni], Visited, FinalVisited) :-
    Limit > 0,
    applicable(
        Az, 
        pos(monster_position, MonsterRow, MonsterCol)
    ),
    transform(Az, pos(monster_position, MonsterRow, MonsterCol), Result),
    check_visited(Az, Result, Visited),
    NewLimit is Limit - 1,
    profondity_search(NewLimit, Result, SeqAzioni, [Result | Visited], FinalVisited).

% Predicato che consente di verificare se la posizione corrente è già stata visitata (presente in Visited).
check_visited(_, pos(monster_position, R, C), Visited) :- 
    \+ member(pos(monster_position, R, C), Visited).
    
% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso nord di una cella.
transform(nord, pos(T, R, C), Result) :- 
    R1 is R - 1,
    Result = pos(T, R1, C), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso sud di una cella.
transform(sud, pos(T, R, C), Result) :- 
    R1 is R + 1,
    Result = pos(T, R1, C), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso est di una cellla.
transform(est, pos(T, R, C), Result) :- 
    C1 is C + 1,
    Result = pos(T, R, C1), !.

% Predicato che consente di trasformare la posizione corrente, spostando il mostro verso ovest di una cella.
transform(ovest, pos(T, R, C), Result) :- 
    C1 is C - 1,
    Result = pos(T, R, C1), !.