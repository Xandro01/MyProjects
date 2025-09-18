import behavior.SellerInformBehavior;
import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.Behaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.UnreadableException;
import util.AgentMessage;
import util.AuctionItem;
import util.ServiceRegister;

public class SellerAgent extends Agent {

    private Boolean flag = false;

    protected void setup() {
        System.out.println("Hello World! I'm a seller and my name is "+getLocalName());
        ServiceRegister.register("seller", "items-seller", "auction-selling", "Java", this);

        String itemName = getArguments()[0].toString();
        int price = Integer.parseInt(getArguments()[1].toString());

        addBehaviour(new SellerInformBehavior(
                new AuctionItem(
                        getAID(),
                        itemName,
                        price
                )
        ));
    } 

    protected void takeDown() {
        ServiceRegister.deregister(this);
    }
}