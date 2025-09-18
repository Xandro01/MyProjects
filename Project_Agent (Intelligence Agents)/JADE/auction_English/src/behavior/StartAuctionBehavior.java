package behavior;

import jade.core.Agent;
import jade.core.behaviours.Behaviour;
import jade.core.behaviours.WakerBehaviour;
import jade.lang.acl.ACLMessage;
import util.AgentMessage;

public class StartAuctionBehavior extends WakerBehaviour {
    private Behaviour responseBehavior;
    public StartAuctionBehavior(Agent a, Behaviour responseBehavior) {
        super(a, 10000);
        this.responseBehavior = responseBehavior;
    }

    @Override
    public void onWake() {

        AgentMessage msg = new AgentMessage(ACLMessage.REQUEST, "seller", myAgent);
        msg.send(myAgent.getAID(), myAgent);

        myAgent.addBehaviour(responseBehavior);
    }
}
