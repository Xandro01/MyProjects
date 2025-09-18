
(deftemplate time
  (slot step)
)

(deftemplate game-difficulty
  (slot difficulty (allowed-values easy hard vhard))
)

(deffacts initial-time
   (time (step -1))
)

(defrule str 
  (declare (salience 10))
=>
  (set-strategy depth)
)

