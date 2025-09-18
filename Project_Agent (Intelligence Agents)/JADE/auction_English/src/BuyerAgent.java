import jade.core.Agent;
import jade.core.behaviours.Behaviour;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import util.AgentMessage;
import util.AuctionItem;
import util.ServiceRegister;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;

public class BuyerAgent extends Agent {

    private int budget = 1000;
    private ArrayList<String> wantedObject = new ArrayList<>();

    protected void setup() {
        System.out.println("Hello World! L'm a buyer and my name is "+getLocalName());
        ServiceRegister.register("buyer", "items-buyer", "auction-buying", "Java", this);

        Object[] args = getArguments();
        int startBudget = Integer.parseInt(args[0].toString());
        this.budget = startBudget;
        for (int i = 1; i < args.length; i++) {
            wantedObject.add(args[i].toString());
        }
        System.out.println("[Buyer:: " + getLocalName() +"] wanted object: " + wantedObject + " for budeget: " + budget);

        // recieve propose and send accept or reject
        addBehaviour(new CyclicBehaviour() {
            @Override
            public void action() {
                AgentMessage msg = AgentMessage.recieve(myAgent, ACLMessage.PROPOSE);
                if (msg != null) {
                    int performative =ACLMessage.REJECT_PROPOSAL;
                    AuctionItem proposedItem = (AuctionItem) msg.getContent();
                    if ( wantedObject.contains(proposedItem.getItem()) && proposedItem.getPrice() <= budget) {
                        performative =ACLMessage.ACCEPT_PROPOSAL;
                        System.out.println("[Buyer:: " + getLocalName() +"] accept: " + proposedItem.getItem() + " for " + proposedItem.getPrice());
                    } else {
                        System.out.println("[Buyer:: " + getLocalName() +"] reject: " + proposedItem.getItem() + " for " + proposedItem.getPrice());
                    }

                    AgentMessage reply = new AgentMessage(msg, performative);
                    reply.send(msg.getContent(), myAgent);
                } else {
                    block();
                }
            }
        });

        addBehaviour(new CyclicBehaviour() {
            @Override
            public void action() {
                AgentMessage msg = AgentMessage.recieve(myAgent, ACLMessage.CONFIRM);
                if (msg != null) {
                    AuctionItem winnedItem = (AuctionItem) msg.getContent();
                    wantedObject.remove(winnedItem);
                    budget -= winnedItem.getPrice();
                    System.out.println("[Buyer:: " + getLocalName() +"] win => my new budeget is " + budget);
                    AgentMessage payamentMSG = new AgentMessage(ACLMessage.INFORM, winnedItem.getOwner());
                    payamentMSG.send(winnedItem.getPrice(), myAgent);
                } else {
                    block();
                }
            }
        });

        addBehaviour(new CyclicBehaviour() {
            @Override
            public void action() {
                AgentMessage msg = AgentMessage.recieve(myAgent, ACLMessage.CANCEL);
                if (msg != null) {
                    myAgent.doDelete();
                } else {
                    block();
                }
            }
        });

    }



    protected void takeDown() {
        ServiceRegister.deregister(this);
    }
}
