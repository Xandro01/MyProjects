package com.example.mailclient;

import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.web.HTMLEditor;
import javafx.stage.Stage;

import java.io.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.net.InetAddress;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

public class NewEmailController {
    @FXML
    private Label from;
    @FXML
    private TextField to;
    @FXML
    private TextField subject;
    @FXML
    private HTMLEditor text;
    @FXML
    private Button sendButton;
    @FXML
    private Button deleteButton;
    private DataModel model;

    public void initModel(DataModel model) {
        if (this.model != null) {
            throw new IllegalStateException("Model can only be initialized once");
        }
        this.model = model;
        this.from.setText(this.model.getCurrentAccount());
        if(this.model.getForwardSelected()){
            this.subject.setText(this.model.getCurrentEmail().getSubject());
            this.subject.setEditable(false);
            this.text.setHtmlText(this.model.getCurrentEmail().getContent());
            this.text.setDisable(true);
        }
        if(this.model.getReplySelected() || this.model.getReplyAllSelected()){
            if(this.model.getReplySelected())
                this.to.setText(this.model.getCurrentEmail().getFrom());
            else if(this.model.getReplyAllSelected()){
                String destinatari = this.model.getCurrentEmail().getFrom();
                String[] users = this.model.getCurrentEmail().getTo().split(", ");
                for(int i = 0; i < users.length; i++) {
                    if(users[i].compareTo(this.model.getCurrentAccount()) != 0)
                        destinatari = destinatari + ", " + users[i];
                }
                this.to.setText(destinatari);
            }
            this.to.setEditable(false);
            this.text.setHtmlText("<div><span contenteditable = 'false'><span style=\"font-size:10px\"><p>In risposta a:<br>" +
                    "Mittente: " + this.model.getCurrentEmail().getFrom() + "<br>" +
                    "CC: " + this.model.getCurrentEmail().getTo() + "<br>" +
                    "Oggetto: " + this.model.getCurrentEmail().getSubject() + "<br>" +
                    "<font color= 'blue'>Testo:</font></p><p>" +
                        this.model.getCurrentEmail().getContent() +
                    "</span></p><p>-----------------------------</p></span></div>");
        }
    }

    @FXML
    protected void onSendButtonClick() {
        if(this.model != null) {
            this.model.setCountOfClick(0);
        }
        Calendar cal = Calendar.getInstance();
        DateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        DateFormat hourFormat = new SimpleDateFormat("HH:mm");

        String[][] newEmailArray = new String[1][7];
        newEmailArray[0][0] = "SNDMSG"; /*send email*/
        newEmailArray[0][1] = this.from.getText();
        newEmailArray[0][2] = this.to.getText();
        newEmailArray[0][3] = this.subject.getText();
        String content = this.text.getHtmlText();
        this.text.setHtmlText("<span contenteditable = 'false'>" + content + "</span>");
        newEmailArray[0][4] = this.text.getHtmlText();
        newEmailArray[0][5] = hourFormat.format(cal.getTime());
        newEmailArray[0][6] = dateFormat.format(cal.getTime());

        try {
            String nomeHost = InetAddress.getLocalHost().getHostName();
            Socket s = new Socket(nomeHost, 9199);
            try {
                ObjectOutputStream outStream = new ObjectOutputStream(s.getOutputStream());
                ObjectInputStream in = new ObjectInputStream(s.getInputStream());
                outStream.writeObject(newEmailArray);

                Boolean flag = (Boolean) in.readObject();
                if(!(flag)){
                    FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("alert-invalidaccount-view.fxml"));
                    Stage stageAlert = new Stage();
                    stageAlert.setTitle("Alert");
                    stageAlert.setScene(new Scene(fxmlloader.load(), 600, 100));
                    stageAlert.setResizable(false);
                    stageAlert.show();
                }else{
                    updateSendEmail(newEmailArray);
                }
            }finally {
                s.close();
            }
        } catch (Exception e) {
            try {
                FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("alert-breakconnection-view.fxml"));
                Stage stageAlert = new Stage();
                stageAlert.setTitle("Alert");
                stageAlert.setScene(new Scene(fxmlloader.load(), 500, 100));
                stageAlert.setResizable(false);
                stageAlert.show();
            } catch (Exception exception){
                exception.printStackTrace();
            }
        }
        Stage stage = (Stage) sendButton.getScene().getWindow();
        stage.close();
    }

    @FXML
    private void deleteNewEmail(){
        Stage stage = (Stage)deleteButton.getScene().getWindow();
        stage.close();
    }

    private void updateSendEmail(String[][] newEmail){
        this.model.getEmailList().add(new Email(newEmail[0][1], newEmail[0][2], newEmail[0][3], newEmail[0][4], newEmail[0][5], newEmail[0][6]));
        this.model.getEmailListSend().clear();
        for (Email email: this.model.getEmailList()) {
            if(email.getFrom().equals(newEmail[0][1])){
                this.model.getEmailListSend().add(email);
            }
        }
        this.model.getEmailListSend().sort(new EmailComparator());
        if(this.model.getOrdinaPer().compareTo("Meno Recente") == 0){
            FXCollections.reverse(this.model.getEmailListSend());
        }
    }
}