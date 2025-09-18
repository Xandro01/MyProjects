package com.example.mailclient;

import javafx.beans.property.SimpleStringProperty;
import javafx.beans.property.StringProperty;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.CheckBox;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

import java.util.Objects;

public class Email extends HBox {
    private final StringProperty from = new SimpleStringProperty();
    private final StringProperty to = new SimpleStringProperty();
    private final StringProperty subject = new SimpleStringProperty();
    private final StringProperty content = new SimpleStringProperty();
    private final StringProperty data = new SimpleStringProperty();
    private final StringProperty ora = new SimpleStringProperty();
    public final StringProperty fromProperty() {
        return this.from;
    }
    public final String getFrom() {
        return this.fromProperty().get();
    }
    public final void setFrom(final String from) {
        this.fromProperty().set(from);
    }
    public final StringProperty oraProperty() { return this.ora; }
    public final StringProperty dataProperty() { return this.data; }
    public final String getData() {
        return this.dataProperty().get();
    }
    public final String getOra() {
        return this.oraProperty().get();
    }
    public final void setOra(final String ora) {
        this.oraProperty().set(ora);
    }
    public final void setData(final String data) {
        this.dataProperty().set(data);
    }
    public final void setCheckBoxVisible(final boolean flag) {
        this.checkEmail.setVisible(flag);
    }
    public final StringProperty toProperty(){
        return this.to;
    }
    public  final String getTo(){
        return this.toProperty().get();
    }
    public final void setTo(final String to) {
        this.toProperty().set(to);
    }
    public final StringProperty subjectProperty(){
        return this.subject;
    }
    public  final String getSubject(){
        return this.subjectProperty().get();
    }
    public final void setSubject(final String subject) {
        this.subjectProperty().set(subject);
    }
    public final StringProperty contentProperty(){
        return this.content;
    }
    public  final String getContent(){ return this.contentProperty().get(); }
    public final void setContent(final String content) {
        this.contentProperty().set(content);
    }

    private VBox boxForEmail;
    private CheckBox checkEmail;

    public Email(String from, String to, String subject, String content, String ora, String data){
        this.setFrom(from);
        this.setContent(content);
        this.setSubject(subject);
        this.setTo(to);
        this.setOra(ora);
        this.setData(data);

        boxForEmail = new VBox();
        checkEmail = new CheckBox();

        Label fromLabel = new Label(from);
        Label toLabel = new Label(to);
        Label subjectLabel = new Label(subject);
        Label oraLabel = new Label(ora);
        Label dataLabel = new Label(data);

        setPrefWidth(200);
        setPrefHeight(76);

        boxForEmail.setPrefWidth(190);
        boxForEmail.setPrefHeight(76);
        boxForEmail.getChildren().addAll(fromLabel, toLabel, subjectLabel, oraLabel, dataLabel);

        checkEmail.setSelected(false);
        checkEmail.setPrefWidth(10);
        checkEmail.setPrefHeight(76);
        checkEmail.setAlignment(Pos.CENTER);
        checkEmail.setPadding(new Insets(0,5,0,0));

        getChildren().addAll(checkEmail, boxForEmail);
    }

    @Override
    public String toString() {
        return "From:" + this.getFrom() + "\nTo:" + this.getTo() + "\nSubject:" + this.getSubject() + "\nOra:" + this.getOra() + "\nData:" + this.getData();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Email email = (Email) o;
        return Objects.equals(from.getValue(), email.from.getValue()) && Objects.equals(to.getValue(), email.to.getValue())
                && Objects.equals(subject.getValue(), email.subject.getValue()) && Objects.equals(content.getValue(), email.content.getValue())
                && Objects.equals(data.getValue(), email.data.getValue()) && Objects.equals(ora.getValue(), email.ora.getValue());
    }

    @Override
    public int hashCode() {
        return Objects.hash(from, to, subject, content, data, ora);
    }
}

