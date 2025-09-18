

// PLANS
+start_preAuction 
    <-
        .print("preparing...");
        ?toSend(Object, StartPrice);
        .print("Sell:", Object, " at ", StartPrice);
        .my_name(Name);
        .send(auctioneer, inform, joinAuction(Name, Object, StartPrice)).

+notPartecipating(Object)
    <-
        true.

+!kqml_received(auctioneer,request,propose(toSell(Name,Object,StartPrice), Price),Mid) <- true.

+payed(Buyer, NewBudget, Object)
    :
        toSend(Object, StartPrice)
    <-
        -toSend(Object, StartPrice);
        .print("Payement recivied").