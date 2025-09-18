/**
 * Determinazione dello stato successivo
**/

:-[det_position].

% Predicato che consente di trasformare la posizione del mostro e delle gemme, spostandoli verso nord a partire dalla posizione corrente.
% I parametri sono:
% - nord: direzione verso cui spostare il mostro
% - [pos(T, R, C)| Tail]: lista delle posizioni correnti.
% - [ HP | TP]: lista delle posizioni aggiornate dopo essere state spostate verso nord.
% - State: stato corrente del gioco
% - HammerTaked: numero di martelli raccolti
% - HammerTaked1: numero di martelli raccolti dopo lo spostamento verso nord di tutte le posizioni. 
% - FreeCells: numero di celle libere.
% - FreeCellsTMP: numero di celle libere dopo lo spostamento verso nord di tutte le posizioni.
transform(nord, [pos(T, R, C)| Tail], [ HP | TP], State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- 
    det_position_nord(pos(T, R, C), R1, State, HammerTaked, NewHammerTaked,  FreeCells, NewFreeCells),
    HP = pos(T, R1, C),
    TMP = pos(T, R, C),
    update_value_in_list(HP, TMP, State, NewState),
    transform(nord, Tail, TP, NewState, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% caso base in cui assegnamo il numero di martelli raccolti e il numero di celle libere dopo lo spostamento verso nord di tutte le posizioni.
transform(nord, [], [], _, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- HammerTaked1 is HammerTaked, FreeCellsTMP = FreeCells, true.

% Predicato che consente di trasformare la posizione del mostro e delle gemme, spostandoli verso sud a partire dalla posizione corrente.
% I parametri sono:
% - sud: direzione verso cui spostare il mostro
% - [pos(T, R, C)| Tail]: lista delle posizioni correnti.
% - [ HP | TP]: lista delle posizioni aggiornate dopo essere state spostate verso sud.
% - State: stato corrente delle gemme e del mostro
% - HammerTaked: numero di martelli raccolti
% - HammerTaked1: numero di martelli raccolti dopo lo spostamento verso sud di tutte le posizioni.
% - FreeCells: numero di celle libere.
% - FreeCellsTMP: numero di celle libere dopo lo spostamento verso sud di tutte le posizioni.
transform(sud, [pos(T, R, C)| Tail], [ HP | TP], State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- 
    det_position_sud(pos(T, R, C), R1, State, HammerTaked, NewHammerTaked, FreeCells, NewFreeCells),
    HP = pos(T, R1, C),
    TMP = pos(T, R, C),
    update_value_in_list(HP, TMP, State, NewState),
    transform(sud, Tail, TP, NewState, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% caso base in cui assegnamo il numero di martelli raccolti e il numero di celle libere dopo lo spostamento verso sud di tutte le posizioni.
transform(sud, [], [], _,  HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- HammerTaked1 is HammerTaked, FreeCellsTMP = FreeCells, true.

% Predicato che consente di trasformare la posizione del mostro e delle gemme, spostandoli verso ovest a partire dalla posizione corrente.
% I parametri sono:
% - ovest: direzione verso cui spostare il mostro
% - [pos(T, R, C)| Tail]: lista delle posizioni correnti.
% - [ HP | TP]: lista delle posizioni aggiornate dopo essere state spostate verso ovest.
% - State: stato corrente delle posizioni delle gemme e del mostro.
% - HammerTaked: numero di martelli raccolti.
% - HammerTaked1: numero di martelli raccolti dopo lo spostamento verso ovest di tutte le posizioni.
% - FreeCells: numero di celle libere.
transform(ovest, [pos(T, R, C)| Tail], [ HP | TP], State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- 
    det_position_ovest(pos(T, R, C), C1, State, HammerTaked, NewHammerTaked, FreeCells, NewFreeCells),
    HP = pos(T, R, C1),
    TMP = pos(T, R, C),
    update_value_in_list(HP, TMP, State, NewState),
    transform(ovest, Tail, TP, NewState, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% caso base in cui assegnamo il numero di martelli raccolti e il numero di celle libere dopo lo spostamento verso ovest di tutte le posizioni.
transform(ovest, [], [], _, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- HammerTaked1 is HammerTaked, FreeCellsTMP = FreeCells, true.

% Predicato che consente di trasformare la posizione del mostro e delle gemme, spostandoli verso est a partire dalla posizione corrente.
% I parametri sono:
% - est: direzione verso cui spostare il mostro
% - [pos(T, R, C)| Tail]: lista delle posizioni correnti.
% - [ HP | TP]: lista delle posizioni aggiornate dopo essere state spostate verso est.
% - State: stato corrente delle posizioni delle gemme e del mostro.
% - HammerTaked: numero di martelli raccolti.
% - HammerTaked1: numero di martelli raccolti dopo lo spostamento verso est di tutte le posizioni.
% - FreeCells: numero di celle libere.
transform(est, [pos(T, R, C)| Tail], [HP | TP], State, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- 
    det_position_est(pos(T, R, C), C1, State, HammerTaked, NewHammerTaked, FreeCells, NewFreeCells),
    HP = pos(T, R, C1),
    TMP = pos(T, R, C),
    update_value_in_list(pos(T, R, C1), TMP, State, NewState),
    transform(est, Tail, TP, NewState, NewHammerTaked, HammerTaked1, NewFreeCells, FreeCellsTMP).

% caso base in cui assegnamo il numero di martelli raccolti e il numero di celle libere dopo lo spostamento verso est di tutte le posizioni. 
transform(est, [], [], _, HammerTaked, HammerTaked1, FreeCells, FreeCellsTMP) :- HammerTaked1 is HammerTaked, FreeCellsTMP = FreeCells, true.
