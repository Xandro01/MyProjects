/**
 * Determinazione della posizione finale data la mossa
**/

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa nord. 
% Questo è il caso in cui il mostro, mentre si spostava verso nord, è passato sopra alla cella in cui risiede il portale.
% I parametri di input sono:
% - pos(monster_position, R, C): la posizione iniziale del mostro
% - R1: la riga in cui si troverà il mostro dopo aver eseguito la mossa nord
% - State: lo stato corrente del gioco
% - HammerTaked: il numero di martelli raccolti dal mostro
% - HammerTaked1: il numero di martelli raccolti dal mostro dopo aver eseguito la mossa nord
% - FreeCells: la lista corrente delle celle libere
% - FreeCellsTMP: la lista delle celle libere dopo aver eseguito la mossa nord
det_position_nord(pos(monster_position, R, C), R1, _, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- 
    pos(portal, R, C),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    R1 is R.

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa nord.
% Questo è il caso in cui il mostro, mentre si spostava verso nord, è passato sopra ad una cella in cui risiede un martello.
% In questo qualora il mostro non avesse già preso quel martello, il numero di martelli raccolti dal mostro viene incrementato di 1.
det_position_nord(pos(monster_position, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(nord, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    RTMP is R - 1,
    pos(hammer, RTMP, C),
    \+ member(pos(empty, RTMP, C), FreeCells),
    NewHammerTaked is HammerTaked + 1,
    append(FreeCells, [pos(empty, RTMP, C)], NewFreeCells),
    det_position_nord(pos(monster_position, RTMP, C), R1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa nord.
% Questo è il caso in cui il mostro, mentre si spostava verso nord, è passato sopra ad una cella in cui risiede un muro distruttibile.
% In questo caso se il muro non fosse già stato distrutto,  viene aggiunta la cella alla lista delle celle libere.
% Inoltre il numero di martelli raccolti dal mostro viene decrementato di 1.
det_position_nord(pos(monster_position, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(nord, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    RTMP is R - 1,
    pos(destroyable_wall, RTMP, C),
    \+ member(pos(empty, RTMP, C), FreeCells),
    NewHammerTaked is HammerTaked - 1,
    append(FreeCells, [pos(empty, RTMP, C)], NewFreeCells),
    det_position_nord(pos(monster_position, RTMP, C), R1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa nord.
% Questo è il caso base in cui il mostro non può più spostarsi verso nord, poichè l'azione nord non risulta applicabile.
det_position_nord(pos(T, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- 
    \+ applicable(nord, pos(T, R,C), State, HammerTaked, FreeCells),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    R1 is R.

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa nord.
% Questo è il caso in cui il mostro può ancora spostarsi verso nord.
det_position_nord(pos(T, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- 
    applicable(nord, pos(T, R,C), State, HammerTaked, FreeCells),
    RTMP is R - 1,
    det_position_nord(pos(T, RTMP, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa sud.
% Questo è il caso base in cui il mostro non può più spostarsi verso sud, poichè l'azione nord non risulta applicabile.
det_position_sud(pos(T, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    \+ applicable(sud, pos(T, R,C), State, HammerTaked, FreeCells),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    R1 is R.

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa sud.
% Questo è il caso in cui il mostro, mentre si spostava verso sud, è passato sopra ad una cella in cui risiede un martello.
% In questo caso qualora il mostro non avesse già preso quel martello, il numero di martelli raccolti dal mostro viene incrementato di 1.
det_position_sud(pos(monster_position, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(sud, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    RTMP is R + 1,
    pos(hammer, RTMP, C),
    \+ member(pos(empty, RTMP, C), FreeCells),
    NewHammerTaked is HammerTaked + 1,
    append(FreeCells, [pos(empty, RTMP, C)], NewFreeCells),
    det_position_sud(pos(monster_position, RTMP, C), R1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa sud.
% Questo è il caso in cui il mostro, mentre si spostava verso sud, è passato sopra ad una cella in cui risiede un muro distruttibile.
% In questo caso se il muro non fosse già stato distrutto,  viene aggiunta la cella alla lista delle celle libere.
% Inoltre il numero di martelli raccolti dal mostro viene decrementato di 1.
det_position_sud(pos(monster_position, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(sud, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    RTMP is R + 1,
    pos(destroyable_wall, RTMP, C),
    \+ member(pos(empty, RTMP, C), FreeCells),
    NewHammerTaked is HammerTaked - 1,
    append(FreeCells, [pos(empty, RTMP, C)], NewFreeCells),
    det_position_sud(pos(monster_position, RTMP, C), R1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa sud.
% Questo è il caso in cui il mostro, mentre si spostava verso sud, è passato sopra alla cella in cui risiede il portale.
det_position_sud(pos(_, R, C), R1, _, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    pos(portal, R, C),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    R1 is R.

% Determina a partire da una posizione iniziale, la riga in cui si troverà il mostro dopo aver eseguito la mossa sud.
% Questo è il caso in cui il mostro può ancora spostarsi verso sud.
det_position_sud(pos(T, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(sud, pos(T, R,C), State, HammerTaked, FreeCells),
    RTMP is R + 1,
    det_position_sud(pos(T, RTMP, C), R1, State,  HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa ovest.
% Questo è il caso base in cui il mostro non può più spostarsi verso ovest, poichè l'azione ovest non risulta applicabile.
det_position_ovest(pos(T, R, C), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    \+ applicable(ovest, pos(T, R, C), State, HammerTaked, FreeCells),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    C1 is C.

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa ovest.
% Questo è il caso in cui il mostro, mentre si spostava verso ovest, è passato sopra ad una cella in cui risiede un martello.
% In questo caso qualora il mostro non avesse già preso quel martello, il numero di martelli raccolti dal mostro viene incrementato di 1.
det_position_ovest(pos(monster_position, R, C), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(ovest, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    CTMP is C - 1,
    pos(hammer, R, CTMP),
    NewHammerTaked is HammerTaked + 1,
    \+ member(pos(empty, R, CTMP), FreeCells),
    append(FreeCells, [pos(empty, R, CTMP)], NewFreeCells),
    det_position_ovest(pos(monster_position, R, CTMP), C1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa ovest.
% Questo è il caso in cui il mostro, mentre si spostava verso ovest, è passato sopra ad una cella in cui risiede un muro distruttibile.
% In questo caso se il muro non fosse già stato distrutto,  viene aggiunta la cella alla lista delle celle libere. 
% Inoltre il numero di martelli raccolti dal mostro viene decrementato di 1.
det_position_ovest(pos(monster_position, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(ovest, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    CTMP is C - 1,
    pos(destroyable_wall, R, CTMP),
    \+ member(pos(empty, R, CTMP), FreeCells),
    NewHammerTaked is HammerTaked - 1,
    append(FreeCells, [pos(empty, R, CTMP)], NewFreeCells),
    det_position_ovest(pos(monster_position, R, CTMP), R1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa ovest.
% Questo è il caso in cui il mostro, mentre si spostava verso ovest, è passato sopra alla cella in cui risiede il portale.
det_position_ovest(pos(monster_position, R, C), C1, _, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    pos(portal, R, C),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    C1 is C.

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa ovest.
% Questo è il caso in cui il mostro può ancora spostarsi verso ovest.
det_position_ovest(pos(T, R, C), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(ovest, pos(T, R, C), State, HammerTaked, FreeCells),
    CTMP is C - 1,
    det_position_ovest(pos(T, R, CTMP), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa est.
% Questo è il caso base in cui il mostro non può più spostarsi verso est, poichè l'azione est non risulta applicabile.
det_position_est(pos(T, R, C), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    \+ applicable(est, pos(T, R, C), State, HammerTaked, FreeCells),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    C1 is C.

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa est.
% Questo è il caso in cui il mostro, mentre si spostava verso est, è passato sopra ad una cella in cui risiede un martello.
% In questo caso qualora il mostro non avesse già preso quel martello, il numero di martelli raccolti dal mostro viene incrementato di 1.
det_position_est(pos(monster_position, R, C), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(est, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    CTMP is C + 1,
    pos(hammer, R, CTMP),
    \+ member(pos(empty, R, CTMP), FreeCells),
    NewHammerTaked is HammerTaked + 1,
    append(FreeCells, [pos(empty, R, CTMP)], NewFreeCells),
    det_position_est(pos(monster_position, R, CTMP), C1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa est.
% Questo è il caso in cui il mostro, mentre si spostava verso est, è passato sopra ad una cella in cui risiede un muro distruttibile.
% In questo caso se il muro non fosse già stato distrutto,  viene aggiunta la cella alla lista delle celle libere.
% Inoltre il numero di martelli raccolti dal mostro viene decrementato di 1.
det_position_est(pos(monster_position, R, C), R1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(est, pos(monster_position, R,C), State, HammerTaked, FreeCells),
    CTMP is C + 1,
    pos(destroyable_wall, R, CTMP),
    \+ member(pos(empty, R, CTMP), FreeCells),
    NewHammerTaked is HammerTaked - 1,
    append(FreeCells, [pos(empty, R, CTMP)], NewFreeCells),
    det_position_est(pos(monster_position, R, CTMP), R1, State, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa est.
% Questo è il caso in cui il mostro, mentre si spostava verso est, è passato sopra alla cella in cui risiede il portale.
det_position_est(pos(monster_position, R, C), C1, _, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    pos(portal, R, C),
    HammerTaked1 is HammerTaked,
    FreeCellsTMP = FreeCells,
    C1 is C.

% Determina a partire da una posizione iniziale, la colonna in cui si troverà il mostro dopo aver eseguito la mossa est.
% Questo è il caso in cui il mostro può ancora spostarsi verso est.
det_position_est(pos(T, R, C), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :-
    applicable(est, pos(T, R, C), State, HammerTaked, FreeCells),
    CTMP is C + 1,
    det_position_est(pos(T, R, CTMP), C1, State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP).