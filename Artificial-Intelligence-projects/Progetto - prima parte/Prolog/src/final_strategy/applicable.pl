/**
 * Mosse applicabili
**/

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord; 
% in particolare, l'azione è applicabile se:
% - la cella a nord della posizione corrente non è una cella di tipo wall.
% - la cella a nord della posizione corrente non è presente una gemma.
% - la cella a nord della posizione corrente non è una cella di tipo destroyable_wall.
%   I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(nord, pos(monster_position, R, C), [_ | GemState], _, _) :-
    R > 0,
    R1 is R - 1,
    \+ member(pos(gem, R1, C), GemState),
    \+ pos(wall, R1, C),
    \+ pos(destroyable_wall, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - HammerTaked: stato del martello (0 = non posseduto)
% - FreeCells: lista delle celle libere nello stato corrente
applicable(nord, pos(monster_position, R, C), [_ | GemState], HammerTaked, FreeCells) :-
    R > 0,
    R1 is R - 1,
    pos(destroyable_wall, R1, C),
    \+ member(pos(empty, R1, C), FreeCells),
    \+ member(pos(gem, R1, C), GemState),
    \+ pos(wall, R1, C),
    HammerTaked > 0.

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord.
% caso in cui c'è un muro distruttibile ma già distrutto, ovvero è presente nelle celle liberate.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - FreeCells: lista delle celle libere nello stato corrente
applicable(nord, pos(monster_position, R, C), [_ | GemState], _, FreeCells) :-
    R > 0,
    R1 is R - 1,
    pos(destroyable_wall, R1, C),
    \+ member(pos(gem, R1, C), GemState),
    \+ pos(wall, R1, C),
    member(pos(empty, R1, C), FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord.
% caso in cui c'è una gemma nella cella a nord della posizione corrente.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% Invochiamo ricorsivamente l'applicable per la nuova gemma.
applicable(nord, pos(monster_position, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    R > 0,
    R1 is R - 1,
    member(pos(gem, R1, C), GemState),
    \+ pos(wall, R1, C),
    \+ pos(destroyable_wall, R1, C),
    applicable(nord, pos(gem, R1, C), [MonsterState | GemState], HammerTaked, FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord, rispetto alla posizione corrente della gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo anche se nella cella a nord non è presente il mostriciattolo,un'altra gemma, un muro, un muro distruttibile o un portale
applicable(nord, pos(gem, R, C), [MonsterState | GemState], _, _) :-
    R > 0,
    R1 is R - 1,
    \+ member(pos(gem, R1, C) , GemState),
    MonsterState \= pos(monster_position, R1, C),
    \+ pos(wall, R1, C),
    \+ pos(destroyable_wall, R1, C),
    \+ pos(portal, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo anche se nella cella a nord non è presente un'altra gemma, un mosticiattolo, un muro, e che il muro distruttibile sia presente 
% nelle celle libere, ovvero che sia stato distrutto
applicable(nord, pos(gem, R, C), [MonsterState | GemState], _, FreeCells) :-
    R > 0,
    R1 is R - 1,
    \+ member(pos(gem, R1, C) , GemState),
    MonsterState \= pos(monster_position, R1, C),
    \+ pos(wall, R1, C),
    pos(destroyable_wall, R1, C),
    member(pos(empty, R1, C), FreeCells),
    \+ pos(portal, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione nord, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui nella cella a nord della posizione corrente della gemma è presente un'altra gemma. Invochiamo ricorsivamente l'applicable per la nuova gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(nord, pos(gem, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    R > 0,
    R1 is R - 1,
    member(pos(gem, R1, C) , GemState),
    MonsterState \= pos(monster_position, R1, C),
    applicable(nord, pos(gem, R1, C), [MonsterState | GemState], HammerTaked, FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est;
% in particolare, l'azione è applicabile se:
% - la cella a est della posizione corrente non è una cella di tipo wall.
% - la cella a est della posizione corrente non è presente una gemma.
% - la cella a est della posizione corrente non è una cella di tipo destroyable_wall.
%   I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(est, pos(monster_position, R, C), [_ | GemState], _, _) :-
    size(_, CS),
    C < CS,
    C1 is C + 1,
    \+ member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    \+ pos(destroyable_wall, R, C1).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - HammerTaked: stato del martello (0 = non posseduto)
% - FreeCells: lista delle celle libere nello stato corrente
applicable(est, pos(monster_position, R, C), [_ | GemState], HammerTaked, FreeCells) :-
    size(_, CS),
    C < CS,
    C1 is C + 1,
    \+ member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    pos(destroyable_wall, R, C1),
    \+ member(pos(empty, R, C1), FreeCells),
    HammerTaked > 0.

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est.
% Questo è il caso in cui c'è un muro distruttibile ma già distrutto, ovvero è presente nelle celle liberate.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - FreeCells: lista delle celle libere nello stato corrente
applicable(est, pos(monster_position, R, C), [_ | GemState], _, FreeCells) :-
    size(_, CS),
    C < CS,
    C1 is C + 1,
    \+ member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    pos(destroyable_wall, R, C1),
    member(pos(empty, R, C1), FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est.
% caso in cui c'è una gemma nella cella a est della posizione corrente.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% Invochiamo ricorsivamente l'applicable per la nuova gemma.
applicable(est, pos(monster_position, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    size(_, CS),
    C < CS,
    C1 is C + 1,
    member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    \+ pos(destroyable_wall, R, C1),
    applicable(est, pos(gem, R, C1), [MonsterState | GemState], HammerTaked, FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est, rispetto alla posizione corrente della gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo se nella cella a est non è presente il mostriciattolo, un'altra gemma, un muro, un muro distruttibile o un portale
applicable(est, pos(gem, R, C), [MonsterState | GemState], _, _) :-
    size(_, CS),
    C < CS,
    C1 is C + 1,
    \+ member(pos(gem, R, C1) , GemState),
    MonsterState \= pos(monster_position, R, C1),
    \+ pos(wall, R, C1),
    \+ pos(destroyable_wall, R, C1),
    \+ pos(portal, R, C1).  

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo se nella cella a est non è presente un'altra gemma, un mostriciattolo, un muro, e 
% che il muro distruttibile sia presente nelle celle libere, ovvero che sia stato distrutto
applicable(est, pos(gem, R, C), [MonsterState | GemState], _, FreeCells) :-
    size(_, CS),
    C < CS,
    C1 is C + 1,
    \+ member(pos(gem, R, C1) , GemState),
    MonsterState \= pos(monster_position, R, C1),
    \+ pos(wall, R, C1),
    pos(destroyable_wall, R, C1),
    member(pos(empty, R, C1), FreeCells),
    \+ pos(portal, R, C1). 

% Predicato che permette di verificare le condizioni di applicabilità dell'azione est, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui nella cella a est della posizione corrente della gemma è presente un'altra gemma. Invochiamo ricorsivamente l'applicable per la nuova gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(est, pos(gem, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    size(_, CS),
    C < CS,
    C1 is C + 1,
    member(pos(gem, R, C1), GemState),
    applicable(est, pos(gem, R, C1), [MonsterState | GemState], HammerTaked, FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud;
% in particolare, l'azione è applicabile se:
% - la cella a sud della posizione corrente non è una cella di tipo wall.
% - la cella a sud della posizione corrente non è presente una gemma.
% - la cella a sud della posizione corrente non è una cella di tipo destroyable_wall.
%   I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(sud, pos(monster_position, R, C), [_ | GemState], _, _) :-
    size(RS, _),
    R < RS,
    R1 is R + 1,
    \+ member(pos(gem, R1, C) , GemState),
    \+ pos(wall, R1, C),
    \+ pos(destroyable_wall, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - HammerTaked: stato del martello (0 = non posseduto)
% - FreeCells: lista delle celle libere nello stato corrente
applicable(sud, pos(monster_position, R, C), [_ | GemState], HammerTaked, FreeCells) :-
    size(RS, _),
    R < RS,
    R1 is R + 1,
    \+ member(pos(gem, R1, C), GemState),
    \+ pos(wall, R1, C),
    pos(destroyable_wall, R1, C),
    \+ member(pos(empty, R1, C), FreeCells),
    HammerTaked > 0.

% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud.
% Questo è il caso in cui c'è un muro distruttibile ma già distrutto, ovvero è presente nelle celle liberate.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - FreeCells: lista delle celle libere nello stato corrente
applicable(sud, pos(monster_position, R, C), [_ | GemState], _, FreeCells) :-
    size(RS, _),
    R < RS,
    R1 is R + 1,
    \+ member(pos(gem, R1, C), GemState),
    \+ pos(wall, R1, C),
    pos(destroyable_wall, R1, C),
    member(pos(empty, R1, C), FreeCells).
 
% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud.
% caso in cui c'è una gemma nella cella a sud della posizione corrente.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% Invochiamo ricorsivamente l'applicable per la nuova gemma.
applicable(sud, pos(monster_position, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    size(RS, _),
    R < RS,
    R1 is R + 1,
    member(pos(gem, R1, C) , GemState),
    \+ pos(wall, R1, C),
    pos(destroyable_wall, R1, C),
    member(pos(empty, R1, C), FreeCells),
    applicable(sud, pos(gem, R1, C), [MonsterState | GemState], HammerTaked, FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud, rispetto alla posizione corrente della gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo se nella cella a sud non è presente il mostriciattolo, un'altra gemma, un muro, un muro distruttibile o un portale
applicable(sud, pos(gem, R, C), [MonsterState | GemState], _, _) :-
    size(RS, _),
    R < RS,
    R1 is R + 1,
    \+ member(pos(gem, R1, C), GemState),
    MonsterState \= pos(monster_position, R1, C),
    \+ pos(wall, R1, C),
    \+ pos(destroyable_wall, R1, C),
    \+ pos(portal, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo se nella cella a sud non è presente un'altra gemma, un mostriciattolo, un muro, e
% che il muro distruttibile sia presente nelle celle libere, ovvero che sia stato distrutto
applicable(sud, pos(gem, R, C), [MonsterState | GemState], _, FreeCells) :-
    size(RS, _),
    R < RS,
    R1 is R + 1,
    \+ member(pos(gem, R1, C), GemState),
    MonsterState \= pos(monster_position, R1, C),
    \+ pos(wall, R1, C),
    pos(destroyable_wall, R1, C),
    member(pos(empty, R1, C), FreeCells),
    \+ pos(portal, R1, C).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione sud, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui nella cella a sud della posizione corrente della gemma è presente un'altra gemma. 
% Invochiamo ricorsivamente l'applicable per la nuova gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(sud, pos(gem, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    size(RS, _),
    R < RS,
    R1 is R + 1,
    member( pos(gem, R1, C) , GemState ),
    MonsterState \= pos(monster_position, R1, C),
    applicable(sud, pos(gem, R1, C), [MonsterState | GemState], HammerTaked, FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest;
% in particolare, l'azione è applicabile se:
% - la cella a ovest della posizione corrente non è una cella di tipo wall.
% - la cella a ovest della posizione corrente non è presente una gemma.
% - la cella a ovest della posizione corrente non è una cella di tipo destroyable_wall.
%   I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(ovest, pos(monster_position, R,C), [_ | GemState], _, _) :-
    C > 0,
    C1 is C - 1,
    \+ member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    \+ pos(destroyable_wall, R, C1).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - HammerTaked: stato del martello (0 = non posseduto)
% - FreeCells: lista delle celle libere nello stato corrente
applicable(ovest, pos(monster_position, R,C), [_ | GemState], HammerTaked, FreeCells) :-
    C > 0,
    C1 is C - 1,
    \+ member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    pos(destroyable_wall, R, C1),
    \+ member(pos(empty, R, C1), FreeCells),
    HammerTaked > 0.

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest.
% Questo è il caso in cui c'è un muro distruttibile ma già distrutto, ovvero è presente nelle celle liberate.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% - FreeCells: lista delle celle libere nello stato corrente
applicable(ovest, pos(monster_position, R,C), [_ | GemState], _, FreeCells) :-
    C > 0,
    C1 is C - 1,
    \+ member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    pos(destroyable_wall, R, C1),
    member(pos(empty, R, C1), FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest.
% caso in cui c'è una gemma nella cella a ovest della posizione corrente.
% I parametri sono:
% - pos(monster_position, R, C): posizione corrente del mostro.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% Invochiamo ricorsivamente l'applicable per la nuova gemma.
applicable(ovest, pos(monster_position, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    C > 0,
    C1 is C - 1,
    member(pos(gem, R, C1) , GemState),
    \+ pos(wall, R, C1),
    \+ pos(destroyable_wall, R, C1),
    applicable(ovest, pos(gem, R, C1), [MonsterState | GemState], HammerTaked, FreeCells).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest, rispetto alla posizione corrente della gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo se nella cella a ovest non è presente il mostriciattolo, un'altra gemma, un muro, un muro distruttibile o un portale
applicable(ovest, pos(gem, R, C), [MonsterState | GemState], _, _) :-
    C > 0,
    C1 is C - 1,
    \+ member(pos(gem, R, C1) , GemState),
    MonsterState \= pos(monster_position, R, C1),
    \+ pos(wall, R, C1),
    \+ pos(destroyable_wall, R, C1),
    \+ pos(portal, R, C1).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui c'è un muro distruttibile non ancora distrutto (non è presente nelle celle liberate) e il mostro ha il martello
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
% In questo caso controlliamo se nella cella a ovest non è presente un'altra gemma, un mostriciattolo, un muro, e
% che il muro distruttibile sia presente nelle celle libere, ovvero che sia stato distrutto
applicable(ovest, pos(gem, R, C), [MonsterState | GemState], _, FreeCells) :-
    C > 0,
    C1 is C - 1,
    \+ member(pos(gem, R, C1) , GemState),
    MonsterState \= pos(monster_position, R, C1),
    \+ pos(wall, R, C1),
    pos(destroyable_wall, R, C1),
    member(pos(empty, R, C1), FreeCells),
    \+ pos(portal, R, C1).

% Predicato che permette di verificare le condizioni di applicabilità dell'azione ovest, rispetto alla posizione corrente della gemma.
% Questo è il caso in cui nella cella a ovest della posizione corrente della gemma è presente un'altra gemma.
% Invochiamo ricorsivamente l'applicable per la nuova gemma.
% I parametri sono:
% - pos(gem, R, C): posizione corrente della gemma.
% - GemState: lista delle posizioni delle gemme aggiornata allo stato corrente
applicable(ovest, pos(gem, R, C), [MonsterState | GemState], HammerTaked, FreeCells) :-
    C > 0,
    C1 is C - 1,
    member(pos(gem, R, C1) , GemState),
    applicable(ovest, pos(gem, R, C1), [MonsterState | GemState], HammerTaked, FreeCells).