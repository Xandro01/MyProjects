% Definizione del labirinto big size few walls
pos(empty, 0, 0).
pos(empty, 0, 1).
pos(empty, 0, 2).
pos(empty, 0, 3).
pos(empty, 0, 4).
pos(empty, 0, 5).
pos(empty, 0, 6).
pos(empty, 0, 7).
pos(empty, 0, 8).  
pos(empty, 0, 9).
pos(empty, 0, 10).
pos(empty, 0, 11).

pos(empty, 1, 0).
pos(empty, 1, 1).
pos(empty, 1, 2).
pos(empty, 1, 3).
pos(empty, 1, 4).
pos(empty, 1, 5).
pos(empty, 1, 6).
pos(empty, 1, 7).
pos(empty, 1, 8).
pos(empty, 1, 9).
pos(empty, 1, 10).
pos(empty, 1, 11).

pos(empty, 2, 0).
pos(portal, 2, 1).  
pos(empty, 2, 2).
pos(empty, 2, 3).
pos(empty, 2, 4).
pos(empty, 2, 5).
pos(empty, 2, 6).
pos(empty, 2, 7).
pos(empty, 2, 8).
pos(empty, 2, 9).
pos(empty, 2, 10).
pos(empty, 2, 11).

pos(empty, 3, 0).
pos(empty, 3, 1).
pos(empty, 3, 2).
pos(empty, 3, 3).
pos(empty, 3, 4).
pos(empty, 3, 5).  
pos(empty, 3, 6).
pos(empty, 3, 7).
pos(empty, 3, 8).
pos(empty, 3, 9).
pos(empty, 3, 10).
pos(empty, 3, 11).

pos(empty, 4, 0).
pos(empty, 4, 1).
pos(empty, 4, 2).
pos(empty, 4, 3).
pos(empty, 4, 4).
pos(empty, 4, 5).  
pos(empty, 4, 6).
pos(empty, 4, 7).
pos(empty, 4, 8).
pos(empty, 4, 9).
pos(empty, 4, 10).
pos(empty, 4, 11).

pos(empty, 5, 0).
pos(empty, 5, 1).
pos(empty, 5, 2).
pos(empty, 5, 3).
pos(empty, 5, 4).
pos(empty, 5, 5).  
pos(empty, 5, 6).
pos(empty, 5, 7).
pos(empty, 5, 8).
pos(empty, 5, 9).
pos(empty, 5, 10).
pos(empty, 5, 11).

pos(empty, 6, 0).
pos(empty, 6, 1).
pos(empty, 6, 2).
pos(empty, 6, 3).
pos(empty, 6, 4).
pos(empty, 6, 5).  
pos(empty, 6, 6).
pos(monster_position, 6, 7).  
pos(empty, 6, 8).
pos(empty, 6, 9).
pos(empty, 6, 10).
pos(empty, 6, 11).

pos(empty, 7, 0).
pos(empty, 7, 1).
pos(empty, 7, 2).
pos(empty, 7, 3).
pos(empty, 7, 4).
pos(empty, 7, 5).  
pos(empty, 7, 6).
pos(empty, 7, 7).
pos(empty, 7, 8).
pos(empty, 7, 9).
pos(empty, 7, 10).
pos(empty, 7, 11).

pos(empty, 8, 0).
pos(empty, 8, 1).
pos(empty, 8, 2).
pos(empty, 8, 3).
pos(empty, 8, 4).  
pos(empty, 8, 5).  
pos(empty, 8, 6).
pos(empty, 8, 7).
pos(empty, 8, 8).
pos(empty, 8, 9).
pos(empty, 8, 10).
pos(empty, 8, 11).

pos(empty, 9, 0).
pos(empty, 9, 1).
pos(empty, 9, 2).
pos(empty, 9, 3).
pos(empty, 9, 4).
pos(empty, 9, 5). 
pos(empty, 9, 6).
pos(empty, 9, 7).
pos(empty, 9, 8).
pos(empty, 9, 9).
pos(empty, 9, 10).
pos(empty, 9, 11).

pos(empty, 10, 0).
pos(empty, 10, 1).
pos(empty, 10, 2).
pos(empty, 10, 3).
pos(empty, 10, 4).
pos(empty, 10, 5).  
pos(empty, 10, 6).
pos(wall, 10, 7).
pos(empty, 10, 8).
pos(empty, 10, 9).
pos(wall, 10, 10).
pos(wall, 10, 11).

pos(empty, 11, 0).
pos(empty, 11, 1).
pos(empty, 11, 2).
pos(empty, 11, 3).
pos(empty, 11, 4).
pos(empty, 11, 5).  
pos(empty, 11, 6).
pos(empty, 11, 7).
pos(empty, 11, 8).
pos(empty, 11, 9).
pos(empty, 11, 10).
pos(portal, 11, 11).

% Azioni possibili
azione(nord).
azione(sud).
azione(est).
azione(ovest).

% Stato del martello (0 = non posseduto)
has_hammer(0).
