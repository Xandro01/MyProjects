// INITIAL BELIAFS





// INITIAL GOALS

// buy( object desired, max percentage of budget can pay )
//!buy(paint, 30).

// PLANS


+start_preAuction <- true.

+!kqml_received(auctioneer,request,propose(toSell(Name,Object,StartPrice), Price),Mid)
    <-
        !decideToBil(Object, Price).


+!decideToBil(Object, Price)
    :
        want(Object) & budget(Budget) & Budget >= Price
    <-
        .my_name(Name);
        .send(auctioneer, accept, joinPropose(Name, Object)).

+!decideToBil(Object, Price)
    :
        budget(Budget) & Budget < Price
    <-
        .my_name(Name);
        .send(auctioneer, reject, joinPropose(Name, Object)).

+!decideToBil(Object, Price)
    :
        not want(Object)
    <-
        .my_name(Name);
        .send(auctioneer, reject, joinPropose(Object, Name)).

@[atomic]
+pay(Seller, Object, Price)
    <-
        ?budget(Budget);
        NewBudget = Budget - Price;
        .send(Seller, tell, payed(NewBudget, Object));
        -budget(Budget);
        +budget(NewBudget).



