/**
 * Funzioni di utilità
**/

extract_values([], []) :- true.

extract_values([_-Value | RestPairs], [Value | RestValues]) :-
    extract_values(RestPairs, RestValues).

transform_to_key_value_column([], []) :- true.

transform_to_key_value_column([pos(T, R, C) | Rest], [C-pos(T, R, C) | RestPairs]) :-
    transform_to_key_value_column(Rest, RestPairs).

sort_by_column(List, SortedList) :-
    transform_to_key_value_column(List, KeyValuePairs),
    keysort(KeyValuePairs, SortedKeyValuePairs),
    extract_values(SortedKeyValuePairs, SortedList).

transform_to_key_value_row([], []) :- true.

transform_to_key_value_row([pos(T, R, C) | Rest], [R-pos(T, R, C) | RestPairs]) :-
    transform_to_key_value_row(Rest, RestPairs).

sort_by_row(List, SortedList) :-
    transform_to_key_value_row(List, KeyValuePairs),
    keysort(KeyValuePairs, SortedKeyValuePairs),
    extract_values(SortedKeyValuePairs, SortedList).

move_monster_position_to_front(List, Result) :-
    partition(monster_position_filter, List, MonsterPositions, OtherPositions),
    append(MonsterPositions, OtherPositions, Result).

monster_position_filter(pos(monster_position, _, _)) :- true.

update_value_in_list(_, _, [], []) :- true.

update_value_in_list(pos(NewT, NewR, NewC), pos(OldT, OldR, OldC), [pos(OldT, OldR, OldC) | OldTail], [pos(NewT, NewR, NewC) | NewTail]) :-
    update_value_in_list(pos(NewT, NewR, NewC), pos(OldT, OldR, OldC), OldTail, NewTail).

update_value_in_list(pos(NewT, NewR, NewC), pos(OldT, OldR, OldC), [pos(T, R, C) | OldTail], [pos(T, R, C) | NewTail]) :-
    (T \= OldT; R \= OldR; C \= OldC),
    update_value_in_list(pos(NewT, NewR, NewC), pos(OldT, OldR, OldC), OldTail, NewTail).