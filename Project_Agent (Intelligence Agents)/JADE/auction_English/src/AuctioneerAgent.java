import behavior.SellObjectBehavior;
import behavior.StartAuctionBehavior;
import jade.core.Agent;
import jade.core.behaviours.Behaviour;
import jade.core.behaviours.OneShotBehaviour;
import jade.core.behaviours.WakerBehaviour;
import jade.lang.acl.ACLMessage;
import util.AgentMessage;
import util.AuctionItem;

import java.util.ArrayList;

public class AuctioneerAgent extends Agent {

    private static final int MAXOBJECTS = 3;

    private int numberOfResponse = 0;
    private ArrayList<AuctionItem> itemsToSell = new ArrayList();

    protected void setup() {
        System.out.println("Hello World! I'm the Auctioneer and my name is "+getLocalName());

        addBehaviour(new StartAuctionBehavior(this, new Behaviour() {
            @Override
            public void action() {
                AgentMessage msg = AgentMessage.recieve(myAgent, ACLMessage.INFORM);
                int responsePerformative = ACLMessage.CONFIRM;
                if (msg != null) {

                    AuctionItem item = (AuctionItem) msg.getContent();

                    if (item != null && numberOfResponse < MAXOBJECTS) {
                        System.out.println("[Auctioneer] Received message: " + item);
                        // There is other space for object to sell
                        itemsToSell.add(item);
                        numberOfResponse++;
                    } else {
                        System.out.println("[Auctioneer] no serializable");
                        responsePerformative = ACLMessage.DISCONFIRM;
                    }
                    if (numberOfResponse == MAXOBJECTS) {
                        myAgent.addBehaviour(new SellObjectBehavior(itemsToSell));
                    }

                    AgentMessage reply = new AgentMessage(msg, responsePerformative);
                    reply.send("auction participating", myAgent);

                } else {
                    // no message
                    block();
                }


            }

            @Override
            public boolean done() {
                return false;
            }
        }));
    } 
}
