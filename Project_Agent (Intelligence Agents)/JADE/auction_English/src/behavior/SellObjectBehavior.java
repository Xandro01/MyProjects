package behavior;

import jade.core.AID;
import jade.core.behaviours.Behaviour;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import util.AgentMessage;
import util.AuctionItem;

import java.util.ArrayList;

public class SellObjectBehavior extends CyclicBehaviour {

    private ArrayList<AuctionItem> itemsToSell;
    public static final int MAXBUYER = 5;
    private Boolean isSelling;

    public SellObjectBehavior(ArrayList<AuctionItem> itemsToSell)  {
        this.itemsToSell = itemsToSell;
        this.isSelling = false;
    }


    @Override
    public void action() {
        // if::not selling AND itemsToSell is not empty
        if (!isSelling && !itemsToSell.isEmpty()) {
            // selling <- true
            isSelling = true;
            // pop first element
            AuctionItem proposeItem = itemsToSell.removeFirst();
            System.out.println("[Auctioneer] Start propose for " + proposeItem);
            // add behavior that sell the object (when complete set selling <-false)
            myAgent.addBehaviour(new Behaviour() {
                private int step = 0;
                private ArrayList<AID> buyerAccept = new ArrayList<>();
                private ArrayList<AID> buyerReject = new ArrayList<>();
                private AuctionItem itemToSell = new AuctionItem(
                        proposeItem.getOwner(),
                        proposeItem.getItem(),
                        proposeItem.getPrice()
                );

                @Override
                public void action() {
                    // SubBehavior::class( item : AuctionItem )
                    switch (step) {
                        case 0 -> { //  case 0: #broadcast propose item
                            //broadcast(buyer)
                            AgentMessage proposeMsg = new AgentMessage(ACLMessage.PROPOSE, "buyer", myAgent);
                            proposeMsg.send(itemToSell, myAgent);
                            System.out.println("[Auctioneer] propose: " + itemToSell);
                            //step++
                            step++;
                        }
                        case 1 -> {  //  case 1: #wait response from all buyer...
                            //msg = recieve()
                            AgentMessage proposeResult = AgentMessage.recieve(myAgent, MessageTemplate.or(MessageTemplate.MatchPerformative(ACLMessage.ACCEPT_PROPOSAL), MessageTemplate.MatchPerformative(ACLMessage.REJECT_PROPOSAL)));
                            if (proposeResult != null) {
                                AID sender = proposeResult.getSender();
                                if (proposeResult.getPerformative() == ACLMessage.ACCEPT_PROPOSAL) {
                                    buyerAccept.add(sender);
                                } else {
                                    buyerReject.add(sender);
                                }
                                //if all response: step++
                                if ((buyerReject.size() + buyerAccept.size()) == MAXBUYER) {
                                    System.out.println("[Auctioneer] All buyer response");
                                    step++;
                                }
                            } else {
                                block();
                            }
                        }
                        case 2 -> { //  case 2: #decide if item is sold or not
                            if (buyerAccept.size() == 1) { //if accepts == 1:
                                //    step++
                                step++;
                            } else if (buyerAccept.isEmpty()) { //if accepts == 0:
                                //selling = false
                                System.out.println("[Auctioneer] Any buyer accept: " + itemToSell);
                                AgentMessage msgToItemOwner = new AgentMessage(ACLMessage.REJECT_PROPOSAL, itemToSell.getOwner());
                                msgToItemOwner.send("Item auction failure", myAgent);
                                System.out.println("[Auctioneer] Inform " + itemToSell.getOwner() + " : auction failed");
                                isSelling = false;
                            } else { //if accepts > 1:
                                //    item.raise(N)
                                itemToSell.raisePrice(100);
                                System.out.println("[Auctioneer] Many buyer accept: " + itemToSell + " price raised to " + itemToSell.getPrice());
                                //    step = 0
                                buyerAccept.clear();
                                buyerReject.clear();
                                step = 0;
                            }
                        }
                        case 3 -> { //  case 3: #send win confirm to buyer
                            //send(winner, win)
                            AID winner = buyerAccept.removeFirst();
                            AgentMessage winResponse = new AgentMessage(ACLMessage.CONFIRM, winner);
                            winResponse.send(itemToSell, myAgent);
                            System.out.println("[Auctioneer] There is a winner: " + winner + " for " + itemToSell);
                            //selling = false
                            isSelling = false;
                        }
                    }

                }

                @Override
                public boolean done() {
                    //  #Done when not selling
                    return !isSelling;
                }
            });
        // else if::not selling AND itemsToSell is empty
        } else if (!isSelling && itemsToSell.isEmpty()) {
            // doDelete()
            AgentMessage finishInformBuyer = new AgentMessage(ACLMessage.CANCEL, "buyer", myAgent);
            finishInformBuyer.send("auction finish", myAgent);
            AgentMessage finishInformSeller = new AgentMessage(ACLMessage.CANCEL, "seller", myAgent);
            finishInformSeller.send("auction finish", myAgent);
            System.out.println("[Auctioneer] Auctio finish");
            myAgent.doDelete();
        }
    }
}
