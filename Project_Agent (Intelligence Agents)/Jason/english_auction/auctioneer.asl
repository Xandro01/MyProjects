// INITIAL BELIEFS
numberOfObject(3).
numberOfBuyer(5).
step(100).

objectList([]).

buyerResponse(0).
partecipatingBuyer([]).

winners([]).
// INITIAL GAOLS

!start_preAuction.

// PLANS


// starting Pre auction: inform seller to send me, the object want to buy
+!start_preAuction 
    <- 
        .print("Starting pre-Auction");
        .broadcast(tell, start_preAuction).


// recieving object to buy ( can sell only N object ) (for objects <= N)
@[atomic]
+!kqml_received(Buyer,inform,joinAuction(Name, Object, StartPrice),Mid)
    :
        not auction_started & numberOfObject(N) & objectList(List) & .length(List, Length) & Length < N
    <-
        !add(List, toSell(Name, Object, StartPrice), NewList);
        !updateObjectList(NewList);
        !start_auction.

// if auction is started, not accept other object to sell
+!kqml_received(Buyer,inform,joinAuction(Name, Object, StartPrice),Mid)
    :
        auction_started
    <-
        .send(Name, tell, notPartecipating(Object)).

// recieving object to buy ( can sell only N object ) ( for objects > N)
+!kqml_received(Buyer,inform,joinAuction(Name, Object, StartPrice),Mid)
    :
        numberOfObject(N) & objectList(List) & .length(List, Length) & Length > N
    <-
        .send(Name, tell, notPartecipating(Object)).

// starting auction
+!start_auction
    :
        not auction_started & numberOfObject(N) & objectList(List) & .length(List, Length) & Length == N
    <-
        +auction_started;
        !sell.

+!start_auction <- .print("#####").

+auction_started <- .print("The Auction started").

// finish auction
+!sell: objectList([]) 
    <- 
        ?winners(List);
        .print("Auction finish");
        .print(List).

+!sell 
    : 
        objectList(List)
    <-
        !pop(List, ToSell, NewList);
        !updateObjectList(NewList);
        toSell(Name, Object, StartPrice) = ToSell;

        -currentSelling(_, _);
        +currentSelling(ToSell, StartPrice);
        -partecipatingBuyer(_);
        +partecipatingBuyer([]);
        -buyerResponse(_);
        +buyerResponse(0);
        .print("###########################");
        .print("Propose:", ToSell, " at ", StartPrice);
        .broadcast(request, propose(ToSell, StartPrice)).

+!raise
    : 
        objectList(List) & currentSelling(ToSell, Price)
    <-
        ?step(RaiseAmount);
        RaisedPrice = Price + RaiseAmount;
        -currentSelling(_, _);
        -partecipatingBuyer(_);
        +partecipatingBuyer([]);
        -buyerResponse(_);
        +buyerResponse(0);
        +currentSelling(ToSell, RaisedPrice);
        .print("-----------------------");
        .print("Propose(raised):", ToSell, " at ", RaisedPrice);
        .broadcast(request, propose(ToSell, RaisedPrice)).

// recieving object to buy ( can sell only N object ) (for objects <= N)
@[atomic]
+!kqml_received(Buyer,accept,joinPropose(Name, Object),Mid)
    :
        partecipatingBuyer(List)
    <-
        !add(List, Name, NewList);
        !updatePartecipatingBuyer(NewList);
        !markBuyerResponse.

@[atomic]
+!kqml_received(Buyer,reject,joinPropose(Name, Object),Mid)
    <-
        !markBuyerResponse.


// mark a new response for buyers
@[atomic]
+!markBuyerResponse <-
    ?buyerResponse(Number);
    -buyerResponse(Number);
    NewNumber = Number + 1;
    +buyerResponse(NewNumber);
    
    !checkBuyerResponse.



+!checkBuyerResponse
    :
        buyerResponse(Number) & numberOfBuyer(NBuyer) & Number = NBuyer & 
        partecipatingBuyer(List) & .length(List, Length) & Length > 1
    <- 
        // all buyer response and more then one accept
        .print("Partecipating: ",List);
        .print("All buyer response, continue for a new propose.");
        !raise.

+!checkBuyerResponse
    :
        buyerResponse(Number) & numberOfBuyer(NBuyer) & Number = NBuyer & 
        partecipatingBuyer(List) & .length(List, Length) & Length == 1
    <- 
        // all buyer response and only one accept
        // send to buyer acution_completed
        ?currentSelling(toSell(Seller, Object, StartPrice), Price);
        List = [ Buyer | [] ];
        .print("Partecipating: ",List);
        .print(Buyer, " Win the Auction");
        ?winners(WinnerList);
        !add(WinnerList, winner(Buyer, Object, Price), NewWinnerList);
        -winners(WinnerList);
        +winners(NewWinnerList);
        .print("###########################");
        .send(Buyer, tell, pay(Seller, Object, Price) );
        !sell.

+!checkBuyerResponse
    :
        buyerResponse(Number) & numberOfBuyer(NBuyer) & Number = NBuyer & 
        partecipatingBuyer(List) & .length(List, Length) & Length == 0
    <- 
        // all buyer response and no one accept
        .print("Partecipating: ",List);
        .print("All buyer response, all reject.");
        !sell.


+!checkBuyerResponse:buyerResponse(Number) & numberOfBuyer(NBuyer) & Number < NBuyer <- true.




// List Util
+!add( List, Element, NewList ) <- NewList = [Element | List].

+!pop( [], Element, NewList )
    <- 
        Element = nothing;
        NewList = [].

+!pop( List, Element, NewList )
    <- 
        [Head | Tail] = List;
        Element = Head;
        NewList = Tail.

        

+!updateObjectList(NewList)  
    :
        objectList(List)
    <- 
        -objectList(List);
        +objectList(NewList).

+!updatePartecipatingBuyer(NewList)  
    :
        partecipatingBuyer(List)
    <- 
        -partecipatingBuyer(List);
        +partecipatingBuyer(NewList).
        