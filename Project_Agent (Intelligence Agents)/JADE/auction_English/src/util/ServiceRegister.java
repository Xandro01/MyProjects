package util;

import jade.core.Agent;
import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;

public class ServiceRegister {
    public static void register(String type, String name, String ontologies, String language, Agent myAgent) {
        ServiceDescription sd = new ServiceDescription();
        sd.setType(type);
        sd.setName(name);
        sd.addOntologies(ontologies);
        sd.addLanguages(language);

        // Creazione della descrizione dell'agente per il DF
        DFAgentDescription dfd = new DFAgentDescription();
        dfd.setName(myAgent.getAID());
        dfd.addServices(sd);

        // Registrazione del servizio nel DF
        try {
            DFService.register(myAgent, dfd);
            System.out.println("Service: " + type + " - register");
        } catch (FIPAException fe) {
            fe.printStackTrace();
        }
    }

    public static void deregister(Agent myAgent) {
        try {
            DFService.deregister(myAgent);
            System.out.println("Service of: " + myAgent.getName() + " - deregister");
        } catch (FIPAException fe) {
            fe.printStackTrace();
        }
    }
}
