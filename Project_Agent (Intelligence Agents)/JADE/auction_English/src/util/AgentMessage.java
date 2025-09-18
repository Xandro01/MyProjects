package util;

import java.io.Serializable;
import java.util.List;

import jade.core.AID;
import jade.core.Agent;
import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import jade.lang.acl.UnreadableException;

public class AgentMessage {

    private ACLMessage msg;
    
    private AgentMessage(ACLMessage message) {
        msg = message;
    }

    public AgentMessage(int performative) {
        msg = new ACLMessage(performative);
    }

    public AgentMessage(ACLMessage reply, int performative) {
        msg = reply.createReply(performative);
    }

    public AgentMessage(AgentMessage reply, int performative) {
        msg = reply.msg.createReply(performative);
    }

    public AgentMessage(int performative, AID recieverAID) {
        msg = new ACLMessage(performative);
        msg.addReceiver(recieverAID);
    }

    public AgentMessage(int performative, List<AID> recieversAID) {
        msg = new ACLMessage(performative);

        for (AID aid : recieversAID) {
            msg.addReceiver(aid);
        }
        
    }

    public AgentMessage(int performative, DFAgentDescription[] recieversAID) {
        msg = new ACLMessage(performative);

        for (DFAgentDescription dfAgentDescription : recieversAID) {
            msg.addReceiver(dfAgentDescription.getName());
        }
    }
    public AgentMessage(int performative, String service, Agent myAgent) {
        msg = new ACLMessage(performative);

        try {
            DFAgentDescription template = getTemplateFromService(service);
            DFAgentDescription[] recieversAID = DFService.search(myAgent, template);

            for (DFAgentDescription dfAgentDescription : recieversAID) {
                msg.addReceiver(dfAgentDescription.getName());
            }
        } catch(FIPAException exception) {
            exception.printStackTrace();
        }
        
    }

    private void setContent(Serializable content) {
        try {
            msg.setContentObject(content);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
    }

    public AID getSender() {
        return msg.getSender();
    }

    public Serializable getContent()  {
        try {
            return msg.getContentObject();
        } catch (UnreadableException e) {
            throw null;
        }
    }

    public ACLMessage getMSG() { return this.msg; }

    public void setPerformative(int performative) {
        msg.setPerformative(performative);
    }

    public int getPerformative() {
        return msg.getPerformative();
    }  

    public void send( Serializable content, Agent myAgent ) {
        setContent(content);
        myAgent.send(msg);
    }

    public static AgentMessage recieve(Agent myAgent) {
        ACLMessage response = myAgent.receive();

        if (response != null) {
            return new AgentMessage(response);
        } else {
            return  null;
        }

    }

    public static AgentMessage recieve(Agent myAgent, MessageTemplate filters) {
        ACLMessage response = myAgent.receive(filters);
        if (response != null) {
            return new AgentMessage(response);
        } else {
            return  null;
        }

    }

    public static AgentMessage recieve(Agent myAgent, int performative ) {
        MessageTemplate filters = MessageTemplate.MatchPerformative(performative);
        return recieve(myAgent, filters);
    }



    // STATIC METHOD
    public static DFAgentDescription getTemplateFromService(String service) {
        DFAgentDescription template = new DFAgentDescription();
        ServiceDescription sd = new ServiceDescription();
        sd.setType(service);
        template.addServices(sd);
        return template;
    }



}
