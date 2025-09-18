package com.example.mailclient;

import javafx.beans.property.StringProperty;

import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.InetAddress;
import java.net.Socket;

public class Notify extends Thread {
    private ClientController controller;
    StringProperty currentAccount;

    public Notify(ClientController controller, StringProperty currentAccount){ this.controller = controller;  this.currentAccount = currentAccount;}

    @Override
    public void run() {
        while(true) {
            try {
                String nomeHost = InetAddress.getLocalHost().getHostName();
                Socket socket = new Socket(nomeHost, 9199);
                try {
                    ObjectOutputStream out = new ObjectOutputStream(socket.getOutputStream());
                    ObjectInputStream in = new ObjectInputStream(socket.getInputStream());

                    String[][] array = new String[1][2];
                    array[0][0] = "HASNOTIFY";
                    array[0][1] = this.currentAccount.get();
                    out.writeObject(array);
                    Boolean flag = (Boolean) in.readObject();
                    if (flag) {
                        this.controller.setRefreshRed();
                    }else{
                        this.controller.setRefreshGrey();
                    }

                } catch (Exception exception) {

                } finally {
                    socket.close();
                    Thread.sleep(3000);
                }
            }catch(Exception e){ }
            }
        }

    public void setController(ClientController controller){
        this.controller = controller;
    }
}
