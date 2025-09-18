package com.example.mailclient;

import javafx.beans.Observable;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.SimpleObjectProperty;
import javafx.beans.property.SimpleStringProperty;
import javafx.beans.property.StringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;
import java.io.File;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.InetAddress;
import java.net.Socket;
import java.util.HashMap;
import java.util.HashSet;

public class DataModel {
    private int countofclick = 0;
    private String ordinaper = "Piu' Recente";
    private Boolean forwardSelected = false;
    private Boolean replySelected = false;
    private Boolean replyAllSelected = false;
    private final ObservableList<Email> emailList = FXCollections.observableArrayList(email ->
            new Observable[] {email.fromProperty(), email.toProperty()});

    private final ObservableList<Email> emailListInBox = FXCollections.observableArrayList(email ->
            new Observable[] {email.fromProperty(), email.toProperty()});

    private final ObservableList<Email> emailListSend = FXCollections.observableArrayList(email ->
            new Observable[] {email.fromProperty(), email.toProperty()});

    private HashMap<Email, String> emailListDelete;

    public DataModel(HashMap<Email, String> hashMap){
        this.emailListDelete = hashMap;
    }

    private final ObservableList<String> options = FXCollections.observableArrayList(
                    "Piu' Recente", "Meno Recente");

    private final ObservableList<String> users = FXCollections.observableArrayList();

    private final ObjectProperty<Email> currentEmail = new SimpleObjectProperty<>(null);

    private final StringProperty currentAccount = new SimpleStringProperty();

    public ObjectProperty<Email> currentEmailProperty() {
        return this.currentEmail;
    }

    public StringProperty currentAccountProperty() { return this.currentAccount; }

    public final Email getCurrentEmail() {
        return currentEmailProperty().get();
    }

    public final void setCurrentEmail(Email email) {
        currentEmailProperty().set(email);
    }

    public final String getCurrentAccount() {
        return currentAccountProperty().get();
    }

    public final void setCurrentAccount(String currentAccount) {
        currentAccountProperty().set(currentAccount);
    }

    public ObservableList<Email> getEmailListSend() {
        return emailListSend ;
    }

    public ObservableList<Email> getEmailListInBox() { return emailListInBox; }

    public HashMap<Email, String> getEmailListDelete() { return emailListDelete; }

    public ObservableList<Email> getEmailList() {
        return emailList ;
    }

    public ObservableList<String> getOptionsList() {
        return options ;
    }

    public ObservableList<String> getUsersList() {
        return users ;
    }

    public int getCountOfClick(){
        return this.countofclick;
    }

    public String getOrdinaPer(){
        return this.ordinaper;
    }

    public Boolean getForwardSelected(){
        return this.forwardSelected;
    }

    public Boolean getReplySelected(){
        return this.replySelected;
    }

    public Boolean getReplyAllSelected(){
        return this.replyAllSelected;
    }

    public void setCountOfClick(int value){
        this.countofclick = value;
    }

    public void setOrdinaPer(String value){
        this.ordinaper = value;
    }

    public void setForwardSelected(Boolean value){
        this.forwardSelected = value;
    }

    public void setReplySelected(Boolean value){
        this.replySelected = value;
    }

    public void setReplyAllSelected(Boolean value){
        this.replyAllSelected = value;
    }
}

