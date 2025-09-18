package behavior;

import jade.core.AID;
import jade.core.behaviours.Behaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import util.AgentMessage;
import util.AuctionItem;

public class SellerInformBehavior extends Behaviour {


    private AuctionItem item;
    private int step = 1;
    private AID auctioneerAID = null;

    public SellerInformBehavior(AuctionItem item) {
        this.item = item;
    }

    @Override
    public void action() {

        switch (step) {
            case 1:
                // recieve message from auctioneer ( return auctioneer AID)
                AgentMessage recievedMsg = AgentMessage.recieve(myAgent, ACLMessage.REQUEST);
                if (recievedMsg != null) {
                    auctioneerAID = (AID) recievedMsg.getContent();
                    if (auctioneerAID != null) {
                        System.out.println("[Seller] Requeted (auction start) by: " + auctioneerAID.getName());
                        step++;
                    } else {
                        myAgent.doDelete();
                    }
                } else {
                    block();
                }
                break;
            case 2:
                // send object to sell to Auctioneer
                AgentMessage sendMsg = new AgentMessage(ACLMessage.INFORM, auctioneerAID);
                sendMsg.send(item, myAgent);
                step++;
                break;
            case 3:
                // wait confirm or disconfirm from Auctioneer
                AgentMessage confirmMsg = AgentMessage.recieve(myAgent, MessageTemplate.MatchSender(auctioneerAID));
                if (confirmMsg != null) {

                    if (confirmMsg.getPerformative() == ACLMessage.CONFIRM) {
                        // confirm
                        System.out.println("[Seller] Sell::confirmed");
                        step++;
                    } else {
                        // disconfirm
                        System.out.println("[Seller] Sell::disconfirmed");
                        myAgent.doDelete();
                    }
                } else {
                    block();
                }
                break;
            case 4:
                // wait result of auction for is object
                AgentMessage resultMsg = AgentMessage.recieve(myAgent, MessageTemplate.or(MessageTemplate.MatchPerformative(ACLMessage.CANCEL), MessageTemplate.MatchPerformative(ACLMessage.INFORM)));
                if (resultMsg != null) {
                    if (resultMsg.getPerformative() == ACLMessage.INFORM) {
                        int payament = (int) resultMsg.getContent();
                        // payament
                        System.out.println("[Seller] Auction::success <- payament: " + payament + " from " + resultMsg.getSender().getLocalName());
                        myAgent.doDelete();
                    } else {
                        // Object no selled
                        System.out.println("[Seller] Auction::failure");
                        myAgent.doDelete();

                    }
                } else {
                    block();
                }
                break;

        }
    }

    @Override
    public boolean done() {
        return false;
    }
}
