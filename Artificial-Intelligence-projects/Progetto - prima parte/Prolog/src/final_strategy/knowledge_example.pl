% Definizione del labirinto example
pos(wall, 0, 0).
pos(hammer, 0, 1).
pos(empty, 0, 2).
pos(empty, 0, 3).
pos(empty, 0, 4).
pos(empty, 0, 5).
pos(empty, 0, 6).
pos(gem, 0, 7).

pos(empty, 1, 0).
pos(empty, 1, 1).
pos(empty, 1, 2).
pos(empty, 1, 3).
pos(wall, 1, 4).
pos(empty, 1, 5).
pos(empty, 1, 6).
pos(empty, 1, 7).

pos(empty, 2, 0).
pos(empty, 2, 1).
pos(empty, 2, 2).
pos(empty, 2, 3).
pos(empty, 2, 4).
pos(empty, 2, 5).
pos(empty, 2, 6).
pos(empty, 2, 7).

pos(empty, 3, 0).
pos(empty, 3, 1).
pos(empty, 3, 2).
pos(empty, 3, 3).
pos(empty, 3, 4).
pos(empty, 3, 5).
pos(empty, 3, 6).
pos(empty, 3, 7).

pos(empty, 4, 0).
pos(empty, 4, 1).
pos(empty, 4, 2).
pos(wall, 4, 3).
pos(gem, 4, 4).
pos(empty, 4, 5).
pos(empty, 4, 6).
pos(empty, 4, 7).

pos(empty, 5, 0).
pos(empty, 5, 1).
pos(empty, 5, 2).
pos(empty, 5, 3).
pos(wall, 5, 4).
pos(wall, 5, 5).
pos(empty, 5, 6).
pos(wall, 5, 7).

pos(empty, 6, 0).
pos(destroyable_wall, 6, 1).
pos(destroyable_wall, 6, 2).
pos(destroyable_wall, 6, 3).
pos(wall, 6, 4).
pos(empty, 6, 5).
pos(empty, 6, 6).
pos(monster_position, 6, 7).

pos(wall, 7, 0).
pos(gem, 7, 1).
pos(empty, 7, 2).
pos(portal, 7, 3).
pos(wall, 7, 4).
pos(wall, 7, 5).
pos(empty, 7, 6).
pos(empty, 7, 7).

azione(nord).
azione(sud).
azione(est).
azione(ovest).

has_hammer(0).