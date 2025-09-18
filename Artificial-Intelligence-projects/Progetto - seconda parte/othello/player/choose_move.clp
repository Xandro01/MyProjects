(deftemplate move
   (slot step)
   (slot row)
   (slot col)
   (slot cost)
)

(defrule forget-past-moves  
  (time (step ?s)) 
  ?m <- (move (step ?s3&:(< ?s3 ?s)) (row ?r) (col ?c))
=>
  (retract ?m)
)

; Consente di cancellare i fatti white-border-counter che hanno uno step vecchio rispetto a quello corrente
(defrule forget-past-counters
  (declare (salience 12))
  ?t <- (time (step ?s))
  ?c <- (white-border-counter (step ?s3&:(< ?s3 ?s)) (position ?pos) (index ?idx) (count ?cnt))
=>
  (retract ?c)
  ;(printout t "Retracted past counter at step " ?s3 crlf)
)

; Consente di gestire l'avanzamento verso una direzione dalla cella di partenza verso quella di destinazione. 
; Questo è il caso in cui la cella corrente è una frontiera e ha il colore nero, in questo caso oltre a ridurre la distanza in celle tra la start cell e la destination cell
; incrementiamo il counter delle frontiere generate.
(defrule increment-cells-selected-frontier-counter
  (declare (salience 10))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?scfc <- (selected-cell-frontier-counter 
             (step ?s) 
             (start_cell ?start_cell) 
             (destination_cell ?destination_cell) 
             (count_frontier ?counter) 
             (direction ?direction) 
             (distance ?distance&:(> ?distance 0)))
  ?cell <- (cell 
             (step ?s) 
             (row ?r&:(eq ?r (+ (fact-slot-value ?start_cell row) (* ?distance (fact-slot-value ?direction row)))))
             (col ?c&:(eq ?c (+ (fact-slot-value ?start_cell col) (* ?distance (fact-slot-value ?direction col)))))
             (content black) 
             (type F))
=>
  (bind ?new-counter (+ ?counter 1))
  (bind ?new-distance (- ?distance 1))
  (modify ?scfc (count_frontier ?new-counter) (distance ?new-distance))
)

; Consente di gestire l'avanzamento verso una direzione dalla cella di partenza verso quella di destinazione. 
; Questo è il caso in cui la cella corrente non è una frontiera e ha un colore diverso dal nero, 
; in questo caso decrementiamo la distanza in celle tra la start cell e la destination cell e
; avanziamo alla cella successiva tra la start_cell e la destination_cell.
(defrule increment-cells-selected-no-frontier-counter
  (declare (salience 10))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?scfc <- (selected-cell-frontier-counter 
             (step ?s) 
             (start_cell ?start_cell) 
             (destination_cell ?destination_cell) 
             (count_frontier ?counter) 
             (direction ?direction) 
             (distance ?distance&:(> ?distance 0)))
  ?cell <- (cell 
             (step ?s) 
             (row ?r&:(eq ?r (+ (fact-slot-value ?start_cell row) (* ?distance (fact-slot-value ?direction row)))))
             (col ?c&:(eq ?c (+ (fact-slot-value ?start_cell col) (* ?distance (fact-slot-value ?direction col)))))
             (content ?content&:(not (eq ?content black)))
             (type ?type&:(not (eq ?type F))))
=>
  (bind ?new-distance (- ?distance 1))
  (modify ?scfc (distance ?new-distance))
)

; Consente di contare il numero di celle bianche presenti nel bordo identificato dalla prima riga (riga 0), nel caso in cui la 
; cella bianca non sia già stata contata (non è presente un counted cell), incrementiamo il contatore e asseriamo il fatto counted cell
; per evitare che la cella sia contata più di una volta.
(defrule count-white-border-cells-row-0 
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?c <- (cell (step ?s) (row 0) (col ?col) (content white))
  (not (counted-cell (step ?s) (row 0) (col ?col)))
  ?b <- (white-border-counter (step ?s) (position row) (index 0) (count ?cnt))
  (test (not (or (eq ?col 0) (eq ?col 7)))) 
=>
  (modify ?b (count (+ ?cnt 1)))
  (assert (counted-cell (step ?s) (row 0) (col ?col)))
  ;(printout t "step " ?s " Counted white cell at row 0 , col" ?col", new count: " (+ ?cnt 1) crlf)
)

; Consente di contare il numero di celle bianche presenti nel bordo identificato dall'ulima riga (riga 7), nel caso in cui la 
; cella bianca non sia già stata contata (non è presente un counted cell), incrementiamo il contatore e asseriamo il fatto counted cell
; per evitare che la cella sia contata più di una volta.
(defrule count-white-border-cells-row-7 
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?c <- (cell (step ?s) (row 7) (col ?col) (content white))
  (not (counted-cell (step ?s) (row 7) (col ?col)))
  ?b <- (white-border-counter (step ?s) (position row) (index 7) (count ?cnt))
  (test (not (or (eq ?col 0) (eq ?col 7)))) 
=>
  (modify ?b (count (+ ?cnt 1)))
  (assert (counted-cell (step ?s) (row 7) (col ?col)))
  ;(printout t "step " ?s " Counted white cell at row  row 7 , col "?col", new count: " (+ ?cnt 1) crlf)
)

; Consente di contare il numero di celle bianche presenti nel bordo identificato dalla prima colonna (colonna 0), nel caso in cui la 
; cella bianca non sia già stata contata (non è presente un counted cell), incrementiamo il contatore e asseriamo il fatto counted cell
; per evitare che la cella sia contata più di una volta.
(defrule count-white-border-cells-col-0 
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?c <- (cell (step ?s) (row ?row) (col 0) (content white))
  (not (counted-cell (step ?s) (row ?row) (col 0)))
  ?b <- (white-border-counter (step ?s) (position col) (index 0) (count ?cnt))
  (test (not (or (eq ?row 0) (eq ?row 7)))) 
=>
  (modify ?b (count (+ ?cnt 1)))
  (assert (counted-cell (step ?s) (row ?row) (col 0)))
  ;(printout t "step " ?s " Counted white cell at row " ?row ", col 0, new count: " (+ ?cnt 1) crlf)
)

; Consente di contare il numero di celle bianche presenti nel bordo identificato dall'ultima colonna (colonna 7), nel caso in cui la 
; cella bianca non sia già stata contata (non è presente un counted cell), incrementiamo il contatore e asseriamo il fatto counted cell
; per evitare che la cella sia contata più di una volta.
(defrule count-white-border-cells-col-7 
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?c <- (cell (step ?s) (row ?row) (col 7) (content white))
  (not (counted-cell (step ?s) (row ?row) (col 7)))
  ?b <- (white-border-counter (step ?s) (position col) (index 7) (count ?cnt))
  (test (not (or (eq ?row 0) (eq ?row 7)))) 
=>
  (modify ?b (count (+ ?cnt 1)))
  (assert (counted-cell (step ?s) (row ?row) (col 7)))
  ;(printout t "step " ?s "Counted white cell at row " ?row ", col 7, new count: " (+ ?cnt 1) crlf)
)

; Consente di contare il numero di celle bianche presenti nell'angolo di un bordo  
; In questo caso il counter viene incrementato sia per la colonna che per le righe
(defrule count-white-border-cells-corner
  (declare (salience 11))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?c <- (cell (step ?s) (row ?row) (col ?col) (content white) (type COR))
  ?b <- (white-border-counter (step ?s) (position row) (index ?row) (count ?rcnt))
  ?r <- (white-border-counter (step ?s) (position col) (index ?col) (count ?ccnt))
  (not (counted-cell (step ?s) (row ?row) (col ?col)))
=>
  (modify ?b (count (+ ?rcnt 1)))
  (modify ?r (count (+ ?ccnt 1)))
  (assert (counted-cell (step ?s) (row ?row) (col ?col)))
  ;(printout t "step " ?s "Counted white CORNER cell at row " ?row ", col " ?col ", new row count: "  (+ ?rcnt 1) ", new col count: " (+ ?ccnt 1)  crlf)
)

(defrule guess-move 
  ?t <- (time (step ?s))
  (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a) (content empty))
=>
  (bind ?s3 (+ ?s 1))
  (assert (move (step ?s3) (row ?r) (col ?c) (cost ?a)))
  (modify ?t (step ?s))
)

; Consente di definire il costo di una cella sulla base della distanza tra la cella e gli angoli.
; Viene calcolata la distanza rispetto a ciascuno di essi e successivamente viene presa la distanza minima.
; Minore è la distanza selezionata, minore sarà il costo.
(defrule update-cost-of-cell (declare (salience 9))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a) (content empty) (type empty))
=>
  (bind ?dist-top-left (sqrt (+ (** (- 0 ?r) 2) (** (- 0 ?c) 2))))
  (bind ?dist-top-right (sqrt (+ (** (- 0 ?r) 2) (** (- 7 ?c) 2))))
  (bind ?dist-bottom-left (sqrt (+ (** (- 7 ?r) 2) (** (- 0 ?c) 2))))
  (bind ?dist-bottom-right (sqrt (+ (** (- 7 ?r) 2) (** (- 7 ?c) 2))))
  (bind ?new-cost (min ?dist-top-left ?dist-top-right ?dist-bottom-left ?dist-bottom-right))
  (modify ?cl (nearCorner ?new-cost))
)

; Consente di definire il costo delle celle adiacenti all'angolo, presenti sulla diagonale.
; Il costo è molto alto poichè posizionare una pedina su questo angolo significa perdere un angolo
(defrule update-cost-of-certain-cell-X (declare (salience 8))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a) (content empty)  (type X))
=>
  (bind ?new-cost 20)
  (modify ?cl (nearCorner ?new-cost))
)

; Consente di definire il costo delle celle adiacenti all'angolo.
; Qualora il nuemero di celle contenenti pedine bianche prsenti sullo stesso bordo della cella tipo C selezionata fosse minore di 3
; La scelta di quella pedina comporta un rischio, pertanto il costo è alto.
(defrule update-cost-of-certain-cell-C (declare (salience 8))
  ?t <- (time (step ?s))
  ?difficulty <- (game-difficulty (difficulty ?d&:(not (eq ?d easy))) )
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a) (content empty) (type C))
  ?b <- (white-border-counter (step ?s) (position ?p ) (index ?i) (count ?cnt)) 
  (test (or (and (eq ?p row) (eq ?i ?r))
            (and (eq ?p col) (eq ?i ?c))))
  (test (< ?cnt 3))
=> 
  (bind ?new-cost 20)
  (modify ?cl (nearCorner ?new-cost))
  ;(printout t "modify cell c " ?r "col " ?c "with counter " ?cnt " and r " ?r crlf)
)

; Questa regola consente di aggiornare il costo di ogni cella in modo tale da tenere conto 
; del numero di frontiere generate nel caso in cui si segliesse la mossa che posiziona una pedina bianca su quella cella.
(defrule update-cell-selected-cost
  (declare (salience 7))
  ?difficulty <- (game-difficulty (difficulty ?d&:(eq ?d vhard)) )
  ?t <- (time (step ?s))
  ?cl <- (cell (step ?s) (row ?r) (col ?c) (nearCorner ?a))
  ?scfc <- (selected-cell-frontier-counter (step ?s) (start_cell ?start_cell) (destination_cell ?destination_cell) (count_frontier ?counter) (direction ?direction) (distance ?distance))
  (test (and (eq ?r (fact-slot-value ?start_cell row)) (eq ?c (fact-slot-value ?start_cell col))))
  (test (eq ?distance 0))
=>
  (bind ?new-cost (+ ?a ?counter))
  (modify ?scfc (distance -1))
  (modify ?cl (nearCorner ?new-cost))
)

