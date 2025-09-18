% Definizione delle squadre
squadra(juventus, torinoAllianz).
squadra(milan, milano).
squadra(inter, milano).
squadra(roma, roma).
squadra(salernitana, salerno).
squadra(torino, torino).
squadra(bologna, bologna).
squadra(udinese, udine).
squadra(napoli, napoli).
squadra(genoa, genova).
squadra(fiorentina, firenze).
squadra(atalanta, bergamo).
squadra(cagliari, cagliari).
squadra(verona, verona).
squadra(empoli, empoli).
squadra(parma, parma).

% Definizione delle giornate
giornata(1..15, andata).
giornata(16..30, ritorno).

% Ogni partita è assegnata ad una giornata valida
1 {
    partita(Giornata, Casa, Trasferta) : 
    giornata(Giornata, _)
} 1 :- match(Casa, Trasferta).

match(Casa, Trasferta) :- squadra(Casa,_), squadra(Trasferta, _), Casa != Trasferta.

% Vincolo: una squadra può partecipare a una sola partita per giornata
:- partita(Giornata, SquadraCasa, SquadraTrasferta), partita(Giornata, SquadraCasa, SquadraTrasferta2), SquadraTrasferta != SquadraTrasferta2.
:- partita(Giornata, SquadraCasa, SquadraTrasferta), partita(Giornata, SquadraCasa2, SquadraTrasferta), SquadraCasa != SquadraCasa2.

% Vincolo: la stessa squadre nella stessa giornata non possono fare la partita di andata e ritorno 
:- partita(Giornata, SquadraCasa, _), partita(Giornata, _, SquadraCasa).

% Vincolo: la stessa partita può avvenire solo in una giornata
:- partita(Giornata, SquadraCasa, SquadraTrasferta), partita(Giornata2, SquadraCasa, SquadraTrasferta), Giornata != Giornata2.

% Vincolo: divisione delle partite di andata (prime 15) e del ritorno (ultime 15)
:- partita(Giornata, SquadraCasa, SquadraTrasferta), partita(Giornata2, SquadraTrasferta, SquadraCasa), giornata(Giornata, andata), giornata(Giornata2, andata).
:- partita(Giornata, SquadraCasa, SquadraTrasferta), partita(Giornata2, SquadraTrasferta, SquadraCasa), giornata(Giornata, ritorno), giornata(Giornata2, ritorno).

%Vincolo: la stessa squadra non deve giocare più di due partite consecutive in casa o in trasferta 
:- partita(Giornata, SquadraCasa, _), partita(Giornata + 1, SquadraCasa, _), partita(Giornata + 2, SquadraCasa, _).
:- partita(Giornata, _, SquadraTrasferta), partita(Giornata + 1, _, SquadraTrasferta), partita(Giornata + 2, _, SquadraTrasferta).

% Vincolo: le squadre con lo stesso stadio non devono giocare in casa contemporaneamente nella stessa giornata
:- partita(Giornata, SquadraCasa, _), squadra(SquadraCasa, Stadio), partita(Giornata, SquadraCasa1, _), squadra(SquadraCasa1, Stadio1), SquadraCasa != SquadraCasa1, Stadio = Stadio1.

% Mostra le partite generate
#show partita/3.
