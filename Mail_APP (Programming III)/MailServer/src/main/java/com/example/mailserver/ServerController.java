package com.example.mailserver;

import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import java.io.*;
import java.util.ArrayList;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class ServerController {
    private ArrayList<String> arrayListLog = new ArrayList<>();

    private ArrayList<Label> arrayListLabel = new ArrayList<>();

    Thread thread;

    private int numeroPaginaCounter = 1;
    @FXML
    private Label log1;

    @FXML
    private Label log2;

    @FXML
    private Label log3;

    @FXML
    private Label log4;

    @FXML
    private Label log5;

    @FXML
    private Label log6;

    @FXML
    private Label log7;

    @FXML
    private Label log8;

    @FXML
    private Label log9;

    @FXML
    private Label log10;

    @FXML
    private Label numeroPagina;

    @FXML
    private Button next;

    @FXML
    private Button previous;

    public void initModel() {
        this.arrayListLabel.add(this.log1);
        this.arrayListLabel.add(this.log2);
        this.arrayListLabel.add(this.log3);
        this.arrayListLabel.add(this.log4);
        this.arrayListLabel.add(this.log5);
        this.arrayListLabel.add(this.log6);
        this.arrayListLabel.add(this.log7);
        this.arrayListLabel.add(this.log8);
        this.arrayListLabel.add(this.log9);
        this.arrayListLabel.add(this.log10);

        JSONObject user1 = new JSONObject();
        user1.put("name","daniela_magrì@edunito.prog3.com");
        JSONArray emailListDelete1 = new JSONArray();
        user1.put("emailListDelete", emailListDelete1);
        JSONArray emailList1 = new JSONArray();
        user1.put("emailList", emailList1);
        user1.put("hasNotify", false);

        JSONObject user2 = new JSONObject();
        user2.put("name","alessandro_scicolone@edunito.prog3.com");
        JSONArray emailListDelete2 = new JSONArray();
        user2.put("emailListDelete", emailListDelete2);
        JSONArray emailList2 = new JSONArray();
        user2.put("emailList", emailList2);
        user2.put("hasNotify", false);

        JSONObject user3 = new JSONObject();
        user3.put("name","patric_reineri@edunito.prog3.com");
        JSONArray emailListDelete3 = new JSONArray();
        user3.put("emailListDelete", emailListDelete3);
        JSONArray emailList3 = new JSONArray();
        user3.put("emailList", emailList3);
        user3.put("hasNotify", false);

        JSONObject user4 = new JSONObject();
        user4.put("name","roberto_esposito@edunito.prog3.com");
        JSONArray emailListDelete4 = new JSONArray();
        user4.put("emailListDelete", emailListDelete4);
        JSONArray emailList4 = new JSONArray();
        user4.put("emailList", emailList4);
        user4.put("hasNotify", false);

        JSONArray jsonArrayUsers = new JSONArray();
        jsonArrayUsers.add(user1);
        jsonArrayUsers.add(user2);
        jsonArrayUsers.add(user3);
        jsonArrayUsers.add(user4);
        JSONObject jsonObjectUsers = new JSONObject();
        jsonObjectUsers.put("ListOfUsers", jsonArrayUsers);

        try {
            FileReader account = new FileReader("MailServer/src/account.json");
        }catch (FileNotFoundException e){
            try {
                FileWriter account = new FileWriter("MailServer/src/account.json");
                account.write(jsonObjectUsers.toJSONString());
                account.flush();
            }catch (Exception exception){
                exception.printStackTrace();
            }
        }
        this.thread = new Thread(new StartServerTask(this));
        this.thread.start();
    }

    @FXML
    private void nextClick() {
        this.numeroPaginaCounter++;
        int initCounter = (this.numeroPaginaCounter * 10) - 11;

        if(initCounter > this.arrayListLog.size()){
            this.numeroPaginaCounter--;
            return;
        }

        this.numeroPagina.setText("" + this.numeroPaginaCounter);

        for (Label label: this.arrayListLabel) {
            label.setText("");
        }

        int i = 0;
        int pos = 0;
        for (String s : this.arrayListLog) {
            if(i >= initCounter && i < (initCounter + 10)) {
                this.arrayListLabel.get(pos).setText(s);
                pos++;
            }
            i++;
        }
    }

    @FXML
    private void previousClick() {
        if(this.numeroPaginaCounter == 1){
            return;
        }

        this.numeroPaginaCounter--;
        this.numeroPagina.setText("" + this.numeroPaginaCounter);

        int initCounter = (this.numeroPaginaCounter * 10) - 10;

        for (Label label: this.arrayListLabel) {
            if(initCounter < this.arrayListLog.size()) {
                label.setText(this.arrayListLog.get(initCounter));
            }else{
                return;
            }
            initCounter++;
        }
    }

    public void setArrayListLog(String elem){
        this.arrayListLog.add(0, elem);
        if(this.numeroPaginaCounter == 1) {
            Platform.runLater(()->{
                int i = 0;
                for (String s : this.arrayListLog) {
                    if(i < 10) {
                        this.arrayListLabel.get(i).setText(s);
                    }else{
                        break;
                    }
                    i++;
                }
            });

        }
    }

    public void close(){
        this.thread.interrupt();
    }

    public boolean checkThread(){
        return this.thread.isInterrupted();
    }
}