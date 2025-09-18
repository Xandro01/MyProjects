package util;

import java.io.Serializable;

import jade.core.AID;

public class AuctionItem implements Serializable {
    private AID owner;
    private String item;
    private int price;

    public AuctionItem(AID owner, String item, int startPrice) {
        this.item = item;
        this.owner = owner;
        this.price = startPrice;
    }

    public AID getOwner() {
        return owner;
    }

    public String getItem() {
        return item;
    }

    public int getPrice() {
        return price;
    }

    public void raisePrice(int amount) {
        this.price += amount;
    }

    @Override
    public String toString() {
        return "#(" + this.item + " of " + this.owner.getLocalName() + " at " + this.price +" )#";
    }
}
