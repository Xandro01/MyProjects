; Template che consente di definire le possibili direzioni per identificare le celle nel quadrato attorno ad una data cella
; le direzioni sono le seguenti:
;            [(-1, -1), (-1, 0), (-1, +1),
;             (0, -1),   cella    (0, +1),
;             (+1, -1), (+1, 0), (+1, +1)] 
(deftemplate cell-direction
    (slot row)
    (slot col)
)

; Consente di gestire il conteggio della cella bianca nei bordi, per gli angoli.
; infatti questi devono essere conteggiati sia rispetto alla riga che alla colonna.
(deftemplate counted-cell
  (slot step)
  (slot row)
  (slot col)
)

; Contatori delle celle bianche presenti nei bordi. Template necessario per la scelta di mettere la pedina nelle celle di tipo C.
; Gli attributi: 
; - step: istanziato con il passo corrente al momento della creazione del contatore.
; - position: può assumere come valori row o col. Insieme a index consente di identificare qual è il bordo per cui contiamo.
; - index: consente di discrimenare tra le righe e colonne del bordo.
; - count: contatore delle celle bianche sul bordo identificato.
(deftemplate white-border-counter
  (slot step)
  (slot position) 
  (slot index) 
  (slot count)
)

; Contatore delle frontiere generate in corrispondenza della selezione di una detereminata cella. 
; Il numero di frontiere generate è calcolato in base alle celle frontiere rese bianche a partire dalla start_cell verso la destination_cell.
; Gli attributi sono i seguenti:
; step: istanziato con il passo corrente al momento della creazione del contatore.
; start_cell: contiene come valori, la riga e la colonna della cella di partenza.
; destination_cell: contiene come valori, la riga e la colonna della cella di destinazione.
; count_frontier contatore delle frontiere generate.
; direction: contiene la direzione verso la quale ci spostiamo, le direzioni sono quelle specificate tramite il template (cell-direction).
; distance: inizialmente contiene la distanza in celle tra la cella di partenza e quella di destinazione, viene decrementato ad ogni spostamento.    
(deftemplate selected-cell-frontier-counter
  (slot step)
  (multislot start_cell)
  (multislot destination_cell)
  (slot count_frontier)
  (multislot direction)
  (slot distance)
)

; Template per la definizione di una cella. Gli attributi sono i seguenti:
; - step: istanziato con il passo corrente al momento della creazione del contatore.
; - row: riga su cui è posizionata la cella.
; - col: colonna su cui è posizionata la cella.
; - nearCorner: Costo associato alla cella.
; - content: indica se la cella è vuota oppure occupata da una pedina nera o bianca.
; - type: Indica il tipo della cella, 
; C per le celle adiacenti all'angolo, COR per gli angoli, A e B per quelle centrali, X per le celle adiacenti sulla diagonale dell'angolo, F per le frontiere
(deftemplate cell
  (slot step)
  (slot row)
  (slot col)
  (slot nearCorner)
  (slot content (allowed-values empty white black))
  (slot type (allowed-values empty COR C A B X F))
)

(deffacts cell-directions
  (cell-direction (row -1) (col -1))
  (cell-direction (row -1) (col 0))
  (cell-direction (row -1) (col +1))
  (cell-direction (row  0) (col -1))
  (cell-direction (row  0) (col +1))
  (cell-direction (row +1) (col -1))
  (cell-direction (row +1) (col 0))
  (cell-direction (row +1) (col +1))
)

(deffacts initialize-white-border-counters
  (white-border-counter (step -1) (position row) (index 0) (count 0))
  (white-border-counter (step -1) (position row) (index 7) (count 0))
  (white-border-counter (step -1) (position col) (index 0) (count 0))
  (white-border-counter (step -1) (position col) (index 7) (count 0))
)

(defrule initialize-white-border-counters 
  (declare (salience 12))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  (not (exists (white-border-counter (step ?s) (position row) (index 0))))
  (not (exists (white-border-counter (step ?s) (position row) (index 7))))
  (not (exists (white-border-counter (step ?s) (position col) (index 0))))
  (not (exists (white-border-counter (step ?s) (position col) (index 7))))
=>
  (assert (white-border-counter (step ?s) (position row) (index 0) (count 0)))
  (assert (white-border-counter (step ?s) (position row) (index 7) (count 0)))
  (assert (white-border-counter (step ?s) (position col) (index 0) (count 0)))
  (assert (white-border-counter (step ?s) (position col) (index 7) (count 0)))
  ;(printout t "Initialized white border counters for step " ?s crlf)
)

(defrule initialize-selected-cell-frontier-counter-bottom
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(< ?r1 ?r2)) (col ?c2&:(eq ?c1 ?c2)) (content white))
  ?direction <- (cell-direction(row 1)  (col 0))
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell)(direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter bottom " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col) crlf)
)

(defrule initialize-selected-cell-frontier-counter-top
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(> ?r1 ?r2)) (col ?c2&:(eq ?c1 ?c2)) (content white))
  ?direction <- (cell-direction(row -1)  (col 0))
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter top " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col)crlf)
)

(defrule initialize-selected-cell-frontier-counter-left
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(eq ?r1 ?r2)) (col ?c2&:(> ?c1 ?c2)) (content white))
  ?direction <- (cell-direction (row 0) (col -1))
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter left " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col) crlf)
)

(defrule initialize-selected-cell-frontier-counter-right
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(eq ?r1 ?r2)) (col ?c2&:(< ?c1 ?c2)) (content white))
  ?direction <- (cell-direction (row 0) (col 1))
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter right " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance  " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col) crlf)
)

(defrule initialize-selected-cell-frontier-counter-diagonal-first-left
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(> ?r1 ?r2)) (col ?c2&:(> ?c1 ?c2) &:(eq (- ?r1 ?c1) (- ?r2 ?c2))) (content white))
  ?direction <- (cell-direction (row -1) (col -1))
  
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter diagonal first left " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance  " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col) crlf)
)

(defrule initialize-selected-cell-frontier-counter-diagonal-first-right
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(< ?r1 ?r2)) (col ?c2&:(< ?c1 ?c2) &:(eq (- ?r1 ?c1) (- ?r2 ?c2))) (content white))
  ?direction <- (cell-direction (row 1) (col 1))
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter diagonal first right " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col) crlf)
)

(defrule initialize-selected-cell-frontier-counter-diagonal-second-left
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(> ?r1 ?r2)) (col ?c2&:(< ?c1 ?c2) &:(eq (+ ?r1 ?c1) (+ ?r2 ?c2))) (content white))
  ?direction <- (cell-direction (row -1) (col 1))
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter diagonal second left " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance  " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col) crlf)
)

(defrule initialize-selected-cell-frontier-counter-diagonal-second-right
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?start_cell <- (cell (step ?s) (row ?r1) (col ?c1) (content empty))
  ?destination_cell <- (cell (step ?s) (row ?r2&:(< ?r1 ?r2)) (col ?c2&:(> ?c1 ?c2) &:(eq (+ ?r1 ?c1) (+ ?r2 ?c2))) (content white))
  ?direction <- (cell-direction (row 1) (col -1))
  (not (exists (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (direction ?direction))))
=>
  (bind ?distance (-  (max (abs (- ?r2 ?r1)) (abs (- ?c2 ?c1) ) ) 1)  )
  (assert (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier 0) (direction ?direction) (distance ?distance)))
  ;(printout t "Initialized selected cell frontier counter diagonal second right " ?s " start cell row " ?r1 " col " ?c1 " destination cell row " ?r2 " col " ?c2 " distance " ?distance " direction: row " (fact-slot-value ?direction row) 
            ;" col " (fact-slot-value ?direction col) crlf)
)

; Aggiunge il tipo X alle celle identificate nelle precondizioni
(defrule set-cell-type-X (declare (salience 12))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a)  (type empty))
  (test (or (and (eq ?r 1) (eq ?c 1)) (and (eq ?r 6) (eq ?c 6)) (and (eq ?r 6) (eq ?c 1)) (and (eq ?r 1) (eq ?c 6))))
=>
  (modify ?cl (type X))
)

; Aggiunge il tipo C alle celle identificate nelle precondizioni
(defrule set-cell-type-C (declare(salience 12))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a) (type empty))
  (test (or (and (eq ?r 1) (eq ?c 0)) 
             (and (eq ?r 0) (eq ?c 1)) 
             (and (eq ?r 0) (eq ?c 6)) 
             (and (eq ?r 1) (eq ?c 7)) 
             (and (eq ?r 6) (eq ?c 0)) 
             (and (eq ?r 7) (eq ?c 1)) 
             (and (eq ?r 7) (eq ?c 6))
             (and (eq ?r 6) (eq ?c 7))))
=>
  (modify ?cl (type C))
)

; Aggiunge il tipo B alle celle identificate nelle precondizioni
(defrule set-cell-type-B (declare(salience 12))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a) (type empty))
  (test (or (and (eq ?r 3) (eq ?c 0)) 
             (and (eq ?r 4) (eq ?c 0)) 
             (and (eq ?r 0) (eq ?c 3)) 
             (and (eq ?r 0) (eq ?c 4)) 
             (and (eq ?r 3) (eq ?c 7)) 
             (and (eq ?r 4) (eq ?c 7)) 
             (and (eq ?r 7) (eq ?c 3)) 
             (and (eq ?r 7) (eq ?c 4))))
=>
  (modify ?cl (type B))
)

; Aggiunge il tipo A alle celle identificate nelle precondizioni
(defrule set-cell-type-A (declare(salience 12))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a) (type empty))
  (test (or (and (eq ?r 0) (eq ?c 2)) 
             (and (eq ?r 0) (eq ?c 5)) 
             (and (eq ?r 2) (eq ?c 0)) 
             (and (eq ?r 5) (eq ?c 0)) 
             (and (eq ?r 7) (eq ?c 2)) 
             (and (eq ?r 7) (eq ?c 5)) 
             (and (eq ?r 2) (eq ?c 7)) 
             (and (eq ?r 5) (eq ?c 7))))
=>
  (modify ?cl (type A))
)

; Consente di identificare le celle frontiere. Una frontiera è una cella che ha almeno una cella empty adiacente.
; Questa regola si attiva per ogni fatto direzione presente nei fatti e per ciascuno controlla se la cella adiacente verso la data direzione è vuota.
; Nel caso in cui sia vero, viene assegnto il tipo F alla cella.
(defrule set-cell-type-F (declare (salience 11))
    ?t <- (time (step ?s))
    ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
    ?cl <- (cell (step ?s) (row ?r) (col ?c) (content ?cont) (type empty))
    (test (not (eq ?cont empty)))
    ?dir <- (cell-direction (row ?rdir) (col ?cdir))
    ?c1dir <- (cell (step ?s) (row ?nr) (col ?nc) (content empty))
    (test (and (eq ?nr (+ ?r ?rdir)) (eq ?nc (+ ?c ?cdir))))
  =>
    (modify ?cl (type F))
    ;(printout t "c1dir: row " ?nr ", col " ?nc crlf)
    (bind ?nr (+ ?r ?rdir))
    (bind ?nc (+ ?c ?cdir))
    ;(printout t "nrow " ?nr " nrcol " ?nc crlf)
    ;(printout t "step " ?s " cell modified: row " ?r ", col " ?c ", because direction row " ?rdir ", col " ?cdir crlf)
)

; Aggiunge il tipo COR alle celle identificate nelle precondizioni
(defrule set-cell-type-cor (declare (salience 12))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a)  (type empty))
  (test (or (and (eq ?r 0) (eq ?c 7)) (and (eq ?r 7) (eq ?c 0)) (and (eq ?r 0) (eq ?c 0)) (and (eq ?r 7) (eq ?c 7))))
=>
  (modify ?cl (type COR))
)





