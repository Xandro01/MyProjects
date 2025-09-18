package com.example.mailclient;

import javafx.beans.Observable;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.AnchorPane;
import javafx.scene.web.WebView;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import java.io.*;
import java.net.ConnectException;
import java.net.InetAddress;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Set;

public class ClientController /*implements Initializable*/ {

    private final ObservableList<Email> searchList = FXCollections.observableArrayList(email ->
            new Observable[]{email.fromProperty(), email.toProperty()});

    private final ObservableList<Email> deleteList = FXCollections.observableArrayList(email ->
            new Observable[]{email.fromProperty(), email.toProperty()});

    @FXML
    private AnchorPane root;

    @FXML
    private Label mittente;

    @FXML
    private Label cc;

    @FXML
    private Label oggetto;

    @FXML
    private Label ora;

    @FXML
    private Label data;

    @FXML
    private Label deleteAllText;

    @FXML
    private ToggleButton inbox;

    @FXML
    private ToggleButton send;

    @FXML
    private ToggleButton deleteEmailList;

    @FXML
    private Button refresh;

    @FXML
    private ImageView refreshImage;

    @FXML
    private Button deleteAll;

    @FXML
    private Button ripristinoEmail;

    @FXML
    private Button deleteAllYes;

    @FXML
    private Button deleteAllNo;

    @FXML
    private Button newEmail;

    @FXML
    private Button reply;

    @FXML
    private Button replyAll;

    @FXML
    private Button delete;

    @FXML
    private Button forward;

    @FXML
    private ComboBox filter;

    @FXML
    private ComboBox usersLogin;

    @FXML
    private TextField search;

    @FXML
    private ListView searchListView;

    @FXML
    private AnchorPane rootSearch;

    @FXML
    private ListView emailListView;

    @FXML
    private WebView visualizer;

    private DataModel model;

    private Notify notify;

    public void initModel(DataModel model) {
        if (this.model != null) {
            throw new IllegalStateException("Model can only be initialized once");
        }

        this.model = model;

        loadUsers();

        filter.setItems(model.getOptionsList());
        usersLogin.setItems(model.getUsersList());
        searchListView.setItems(searchList);

        this.send.selectedProperty().addListener((obs, oldValue, newValue) -> {
            if (newValue) {
                this.send.setStyle("-fx-background-color: darkblue;");
                this.inbox.setStyle("-fx-background-color: grey;");
                this.deleteEmailList.setStyle("-fx-background-color: grey;");
            } else {
                this.deleteEmailList.setStyle("-fx-background-color: grey;");
                this.send.setStyle("-fx-background-color: grey;");
                this.inbox.setStyle("-fx-background-color: grey;");
            }
        });

        this.inbox.selectedProperty().addListener((obs, oldValue, newValue) -> {
            if (newValue) {
                this.inbox.setStyle("-fx-background-color: darkblue;");
                this.send.setStyle("-fx-background-color: grey;");
                this.deleteEmailList.setStyle("-fx-background-color: grey;");
            } else {
                this.deleteEmailList.setStyle("-fx-background-color: grey;");
                this.send.setStyle("-fx-background-color: grey;");
                this.inbox.setStyle("-fx-background-color: grey;");
            }
        });

        this.deleteEmailList.selectedProperty().addListener((obs, oldValue, newValue) -> {
            if (newValue) {
                this.deleteEmailList.setStyle("-fx-background-color: darkblue;");
                this.send.setStyle("-fx-background-color: grey;");
                this.inbox.setStyle("-fx-background-color: grey;");
            } else {
                this.deleteEmailList.setStyle("-fx-background-color: grey;");
                this.send.setStyle("-fx-background-color: grey;");
                this.inbox.setStyle("-fx-background-color: grey;");
            }
        });

        this.model.currentAccountProperty().addListener((obs, oldAccount, newAccount) -> {
            updateAccount(newAccount, oldAccount);
            this.send.setSelected(false);
            this.inbox.setSelected(false);
            this.deleteEmailList.setSelected(false);
        });

        this.model.currentEmailProperty().addListener((obs, oldEmail, newEmail) -> {
            if (oldEmail != null) {
                this.mittente.textProperty().unbindBidirectional(oldEmail.fromProperty());
                this.cc.textProperty().unbindBidirectional(oldEmail.toProperty());
                this.oggetto.textProperty().unbindBidirectional(oldEmail.subjectProperty());
                this.ora.textProperty().unbindBidirectional(oldEmail.oraProperty());
                this.data.textProperty().unbindBidirectional(oldEmail.dataProperty());
                this.visualizer.getEngine().loadContent("");
            }
            if (newEmail == null) {
                this.mittente.setText("");
                this.cc.setText("");
                this.oggetto.setText("");
                this.ora.setText("");
                this.data.setText("");
                this.visualizer.getEngine().loadContent("");
            } else {
                this.mittente.textProperty().bindBidirectional(newEmail.fromProperty());
                this.cc.textProperty().bindBidirectional(newEmail.toProperty());
                this.oggetto.textProperty().bindBidirectional(newEmail.subjectProperty());
                this.ora.textProperty().bindBidirectional(newEmail.oraProperty());
                this.data.textProperty().bindBidirectional(newEmail.dataProperty());
                this.visualizer.getEngine().loadContent(newEmail.getContent());
            }
        });

        emailListView.getSelectionModel().selectedItemProperty().addListener((obs, oldSelection, newSelection) ->
                this.model.setCurrentEmail((Email) newSelection));

        this.model.currentEmailProperty().addListener((obs, oldEmail, newEmail) -> {
            emailListView.getSelectionModel().select(newEmail);
        });
    }

    public void setRefreshRed() {
        refreshImage.getParent().setStyle("-fx-background-color: red");
    }
    public void setRefreshGrey() {
        refreshImage.getParent().setStyle("-fx-background-color: grey");
    }

    /*@Override
    public void initialize(URL url, ResourceBundle resourceBundle) {

    }*/

    @FXML
    private void oninboxclick() {
        this.emailListView.setItems(this.model.getEmailListInBox());
        if (!(this.model.getEmailListInBox().isEmpty())) {
            this.model.setCurrentEmail(this.model.getEmailListInBox().get(0));
        }
    }

    @FXML
    private void onsendclick() {
        this.emailListView.setItems(this.model.getEmailListSend());
        if (!(this.model.getEmailListSend().isEmpty())) {
            this.model.setCurrentEmail(this.model.getEmailListSend().get(0));
        }
    }

    @FXML
    private void ondeleteclick() {
        Set<Email> set = this.model.getEmailListDelete().keySet();
        for (Email e : set) {
            if (((this.model.getEmailListDelete().get(e).compareTo("false")) == 0) && (!(this.deleteList.contains(e)))) {
                CheckBox checkBox = (CheckBox) e.getChildren().get(0);
                checkBox.setSelected(false);
                this.deleteList.add(e);
            }
        }
        this.deleteList.sort(new EmailComparator());
        if (this.model.getOrdinaPer().compareTo("Meno Recente") == 0) {
            FXCollections.reverse(this.deleteList);
        }
        this.emailListView.setItems(this.deleteList);
        if (!(this.deleteList.isEmpty())) {
            this.model.setCurrentEmail(this.deleteList.get(0));
        }
    }

    @FXML
    private void deleteallclick() {
        try {
            int count = 0;
            if (!(this.deleteEmailList.isSelected())) {
                for (Email email : this.model.getEmailList()) {
                    CheckBox checkBox = (CheckBox) email.getChildren().get(0);
                    if (checkBox.isSelected()) {
                        count++;
                    }
                }
                if (count == 0) {
                    return;
                }
            } else {
                for (Email email : this.deleteList) {
                    CheckBox checkBox = (CheckBox) email.getChildren().get(0);
                    if (checkBox.isSelected()) {
                        count++;
                    }
                }
                if (count == 0) {
                    return;
                }
            }

            root.setDisable(true);

            FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("alert-deleteallemail-view.fxml"));
            Stage stageAlert = new Stage();
            stageAlert.setTitle("Alert");
            fxmlloader.setController(this);
            stageAlert.setScene(new Scene(fxmlloader.load(), 400, 150));
            stageAlert.setResizable(false);
            stageAlert.initStyle(StageStyle.UNDECORATED);

            if (this.deleteEmailList.isSelected())
                this.deleteAllText.setText("Sei sicuro di voler eliminare DEFINITIVAMENTE le email selezionate?");

            stageAlert.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void deleteallclick_yes() {
        Stage stage = (Stage) deleteAllYes.getScene().getWindow();
        stage.close();

        root.setDisable(false);

        ArrayList<Email> list = new ArrayList<>();
        if (!(this.deleteEmailList.isSelected())) {
            for (Email email : this.model.getEmailList()) {
                CheckBox checkBox = (CheckBox) email.getChildren().get(0);
                if (checkBox.isSelected()) {
                    list.add(email);
                }
            }
        } else {
            for (Email email : this.deleteList) {
                CheckBox checkBox = (CheckBox) email.getChildren().get(0);
                if (checkBox.isSelected()) {
                    list.add(email);
                }
            }
        }
        if (list.size() > 0) {
            for (Email email : list) {
                if (this.deleteEmailList.isSelected()) {
                    this.model.getEmailListDelete().replace(email, "true");
                    this.deleteList.remove(email);
                } else {
                    this.model.getEmailListDelete().put(email, "false");
                }
                this.model.getEmailList().remove(email);
                if (this.send.isSelected()) {
                    this.model.getEmailListSend().remove(email);
                } else {
                    this.model.getEmailListInBox().remove(email);
                }
            }
        }
    }

    @FXML
    private void deleteallclick_no() {
        Stage stage = (Stage) deleteAllNo.getScene().getWindow();
        stage.close();

        root.setDisable(false);
    }

    @FXML
    private void ripristinoEmailClick() {
        if (this.deleteEmailList.isSelected()) {
            ArrayList<Email> list = new ArrayList<>();
            for (Email email : this.deleteList) {
                CheckBox checkBox = (CheckBox) email.getChildren().get(0);
                if (checkBox.isSelected()) {
                    list.add(email);
                }
            }
            if (list.size() > 0) {
                for (Email email : list) {
                    CheckBox checkBox = (CheckBox) email.getChildren().get(0);
                    checkBox.setSelected(false);
                    this.deleteList.remove(email);
                    this.model.getEmailListDelete().replace(email, "ripristino");
                    this.model.getEmailList().add(email);
                    if (email.getFrom().compareTo(this.model.getCurrentAccount()) == 0) {
                        this.model.getEmailListSend().add(email);
                    } else {
                        this.model.getEmailListInBox().add(email);
                    }
                }
                this.model.getEmailListSend().sort(new EmailComparator());
                this.model.getEmailListInBox().sort(new EmailComparator());
                if (this.model.getOrdinaPer().compareTo("Meno Recente") == 0) {
                    FXCollections.reverse(this.model.getEmailListSend());
                    FXCollections.reverse(this.model.getEmailListInBox());
                }
            }
        } else {
            return;
        }
    }

    // It creates a new window when the button is clicked by the user
    @FXML
    private void newemailclick() {
        if (usersLogin.getSelectionModel().getSelectedItem() == null) {
            return;
        }

        try {
            if (this.model.getCountOfClick() == 1) {
                this.model.setCountOfClick(2);
                FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("alert-newemail-view.fxml"));
                Stage stageAlert = new Stage();
                stageAlert.setTitle("Alert");
                fxmlloader.setController(this);
                stageAlert.setScene(new Scene(fxmlloader.load(), 500, 100));
                stageAlert.setResizable(false);
                stageAlert.show();
            } else if (this.model.getCountOfClick() == 0) {
                this.model.setCountOfClick(1);
                FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("new-email-view.fxml"));
                Stage stageNewEmail = new Stage();
                stageNewEmail.setTitle("Nuova Email");
                stageNewEmail.setScene(new Scene(fxmlloader.load(), 700, 310));
                NewEmailController newEmailController = fxmlloader.getController();
                newEmailController.initModel(this.model);
                stageNewEmail.setOnCloseRequest(event -> {
                    this.model.setCountOfClick(0);
                });
                stageNewEmail.show();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @FXML
    private void replyclick() {
        if (this.model.getCurrentEmail() != null) {
            this.model.setReplySelected(true);
            try {
                if (this.model.getCountOfClick() == 1) {
                    this.model.setCountOfClick(2);
                    FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("alert-newemail-view.fxml"));
                    Stage stageAlert = new Stage();
                    stageAlert.setTitle("Alert");
                    fxmlloader.setController(this);
                    stageAlert.setScene(new Scene(fxmlloader.load(), 500, 100));
                    stageAlert.setResizable(false);
                    stageAlert.show();
                } else if (this.model.getCountOfClick() == 0) {
                    this.model.setCountOfClick(1);
                    FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("new-email-view.fxml"));
                    Stage stageNewEmail = new Stage();
                    stageNewEmail.setTitle("Nuova Email");
                    stageNewEmail.setScene(new Scene(fxmlloader.load(), 700, 310));
                    NewEmailController newEmailController = fxmlloader.getController();
                    newEmailController.initModel(this.model);
                    stageNewEmail.setOnCloseRequest(event -> {
                        this.model.setCountOfClick(0);
                    });
                    stageNewEmail.show();
                    this.model.setReplySelected(false);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            return;
        }
    }

    @FXML
    private void replyallclick() {
        if (this.model.getCurrentEmail() != null) {
            this.model.setReplyAllSelected(true);
            try {
                if (this.model.getCountOfClick() == 1) {
                    this.model.setCountOfClick(2);
                    FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("alert-newemail-view.fxml"));
                    Stage stageAlert = new Stage();
                    stageAlert.setTitle("Alert");
                    fxmlloader.setController(this);
                    stageAlert.setScene(new Scene(fxmlloader.load(), 500, 100));
                    stageAlert.setResizable(false);
                    stageAlert.show();
                } else if (this.model.getCountOfClick() == 0) {
                    this.model.setCountOfClick(1);
                    FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("new-email-view.fxml"));
                    Stage stageNewEmail = new Stage();
                    stageNewEmail.setTitle("Nuova Email");
                    stageNewEmail.setScene(new Scene(fxmlloader.load(), 700, 310));
                    NewEmailController newEmailController = fxmlloader.getController();
                    newEmailController.initModel(this.model);
                    stageNewEmail.setOnCloseRequest(event -> {
                        this.model.setCountOfClick(0);
                    });
                    stageNewEmail.show();
                    this.model.setReplyAllSelected(false);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            return;
        }
    }

    @FXML
    private void forwardclick() {
        if (this.model.getCurrentEmail() != null) {
            this.model.setForwardSelected(true);
            try {
                if (this.model.getCountOfClick() == 1) {
                    this.model.setCountOfClick(2);
                    FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("alert-newemail-view.fxml"));
                    Stage stageAlert = new Stage();
                    stageAlert.setTitle("Alert");
                    fxmlloader.setController(this);
                    stageAlert.setScene(new Scene(fxmlloader.load(), 500, 100));
                    stageAlert.setResizable(false);
                    stageAlert.show();
                } else if (this.model.getCountOfClick() == 0) {
                    this.model.setCountOfClick(1);
                    FXMLLoader fxmlloader = new FXMLLoader(getClass().getResource("new-email-view.fxml"));
                    Stage stageNewEmail = new Stage();
                    stageNewEmail.setTitle("Nuova Email");
                    stageNewEmail.setScene(new Scene(fxmlloader.load(), 700, 310));
                    NewEmailController newEmailController = fxmlloader.getController();
                    newEmailController.initModel(this.model);
                    stageNewEmail.setOnCloseRequest(event -> {
                        this.model.setCountOfClick(0);
                    });
                    stageNewEmail.show();
                    this.model.setForwardSelected(false);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            return;
        }
    }

    @FXML
    private void deleteclick() {
        if (this.model.getCurrentEmail() != null) {
            if (this.deleteEmailList.isSelected()) {
                this.model.getEmailListDelete().replace(this.model.getCurrentEmail(), "true");
                this.deleteList.remove(this.model.getCurrentEmail());
            } else {
                this.model.getEmailListDelete().put(this.model.getCurrentEmail(), "false");
            }
            this.model.getEmailList().remove(this.model.getCurrentEmail());
            if (this.send.isSelected()) {
                this.model.getEmailListSend().remove(this.model.getCurrentEmail());
            } else {
                this.model.getEmailListInBox().remove(this.model.getCurrentEmail());
            }
        }
    }

    @FXML
    private void onsearch() {
        if (usersLogin.getSelectionModel().getSelectedItem() == null) {
            return;
        }

        String text = search.getText();

        this.searchList.clear();
        for (Email email : this.model.getEmailList()) {
            if (email.getFrom().contains(text) || email.getTo().contains(text) || email.getContent().contains(text) || email.getSubject().contains(text)) {
                Email copy = new Email(email.getFrom(), email.getTo(), email.getSubject(), email.getContent(), email.getOra(), email.getData());
                this.searchList.add(copy);
                copy.setCheckBoxVisible(false);
            }
        }
        rootSearch.setDisable(false);
        searchListView.setVisible(true);
    }

    @FXML
    private void searchSelect() {
        if (searchListView.getSelectionModel().getSelectedItem() == null) {
            return;
        }

        rootSearch.setDisable(true);
        searchListView.setVisible(false);

        this.model.setCurrentEmail(this.model.getEmailList().get(this.model.getEmailList().indexOf(searchListView.getSelectionModel().getSelectedItem())));
    }

    @FXML
    private void onfilter() {
        this.model.setOrdinaPer(this.filter.getSelectionModel().getSelectedItem().toString());

        if (this.emailListView.getItems().size() > 0) {
            if (filter.getSelectionModel().isSelected(0)) {
                this.model.getEmailListInBox().sort(new EmailComparator());
                this.model.getEmailListSend().sort(new EmailComparator());
                this.deleteList.sort(new EmailComparator());
            } else {
                FXCollections.reverse(this.model.getEmailListInBox());
                FXCollections.reverse(this.model.getEmailListSend());
                FXCollections.reverse(this.deleteList);
            }
            if ((this.inbox.isSelected()) && (this.model.getEmailListInBox() != null)) {
                this.emailListView.setItems(this.model.getEmailListInBox());
                this.model.setCurrentEmail(this.model.getEmailListInBox().get(0));
            } else if ((this.send.isSelected()) && (this.model.getEmailListSend() != null)) {
                this.emailListView.setItems(this.model.getEmailListSend());
                this.model.setCurrentEmail(this.model.getEmailListSend().get(0));
            } else if ((this.deleteEmailList.isSelected()) && (this.deleteList != null)) {
                this.emailListView.setItems(this.deleteList);
                this.model.setCurrentEmail(this.deleteList.get(0));
            }
        }
    }

    @FXML
    private void userslogin() {
        this.model.setCurrentAccount((String) usersLogin.getSelectionModel().getSelectedItem());
    }

    @FXML
    private void refreshEmail() {
        if (usersLogin.getSelectionModel().getSelectedItem() == null) {
            return;
        } else {
            String[][] arrayReset = new String[1][2];
            arrayReset[0][0] = "RESETNOTIFY";
            arrayReset[0][1] = this.model.getCurrentAccount();
            try {
                String nomeHost = InetAddress.getLocalHost().getHostName();
                Socket s = new Socket(nomeHost, 9199);
                try {
                    ObjectOutputStream outStream = new ObjectOutputStream(s.getOutputStream());
                    ObjectInputStream inStream = new ObjectInputStream(s.getInputStream());
                    outStream.writeObject(arrayReset);
                    Boolean flag = (Boolean) inStream.readObject();
                } finally {
                    s.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
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

            updateAccount(this.model.getCurrentAccount(), this.model.getCurrentAccount());
            this.send.setSelected(false);
            this.inbox.setSelected(false);
            this.deleteEmailList.setSelected(false);
        }
    }

    private void updateAccount(String newAccount, String oldAccount) {
        this.model.getEmailList().clear();
        this.model.getEmailListInBox().clear();
        this.model.getEmailListSend().clear();

        String[][] emailArrayDelete = null;
        if (!(this.model.getEmailListDelete().isEmpty()) && (oldAccount != null)) {
            int i = 0;
            Set<Email> set = this.model.getEmailListDelete().keySet();
            emailArrayDelete = new String[set.size()][9];
            for (Email e : set) {
                emailArrayDelete[i][0] = "DLEML"; /*passo al server l'email eliminate per l'account appena caambiato*/
                emailArrayDelete[i][1] = oldAccount;
                emailArrayDelete[i][2] = e.getFrom();
                emailArrayDelete[i][3] = e.getTo();
                emailArrayDelete[i][4] = e.getSubject();
                emailArrayDelete[i][5] = e.getContent();
                emailArrayDelete[i][6] = e.getOra();
                emailArrayDelete[i][7] = e.getData();
                emailArrayDelete[i][8] = this.model.getEmailListDelete().get(e);
                i++;
            }
        }

        this.model.getEmailListDelete().clear();
        this.deleteList.clear();

        String[][] array = new String[1][2];
        array[0][0] = "RQSTACC"; /*request email for this account*/
        array[0][1] = newAccount;

        if(this.notify == null) {
            this.notify = new Notify(this, this.model.currentAccountProperty());
            this.notify.start();
        }

        try {
            String nomeHost = InetAddress.getLocalHost().getHostName();
            Socket s = new Socket(nomeHost, 9199);
            try {
                ObjectOutputStream outStream = new ObjectOutputStream(s.getOutputStream());
                ObjectInputStream in = new ObjectInputStream(s.getInputStream());
                if(emailArrayDelete != null){
                    outStream.writeObject(emailArrayDelete);
                }
                outStream.writeObject(array);

                String[][] email = (String[][]) in.readObject();

                refreshImage.getParent().setStyle("-fx-background-color: grey");

                for (int i = 1; i < email.length; i++) {
                    Email a = new Email(email[i][2], email[i][3], email[i][1], email[i][4], email[i][5], email[i][0]);
                    if ((email[i][6].compareTo("false")) == 0)
                        this.model.getEmailList().add(a);
                    else
                        this.model.getEmailListDelete().put(a, "false");
                }
            } finally {
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

        for (Email email : this.model.getEmailList()) {
            String[] userTo = email.getTo().split(", ");
            for (int i = 0; i < userTo.length; i++) {
                if (userTo[i].equals(newAccount)) {
                    this.model.getEmailListInBox().add(email);
                }
            }
            if (email.getFrom().equals(newAccount)) {
                this.model.getEmailListSend().add(email);
            }
        }

        this.model.getEmailListInBox().sort(new EmailComparator());
        this.model.getEmailListSend().sort(new EmailComparator());
        this.emailListView.setItems(this.model.getEmailListInBox());
    }

    private void loadUsers() {
        String[][] reqUsers = new String[1][1];
        reqUsers[0][0] = "SNDALLUSR";

        try {
            String nomeHost = InetAddress.getLocalHost().getHostName();
            Socket s = new Socket(nomeHost, 9199);
            try {
                ObjectOutputStream outStream = new ObjectOutputStream(s.getOutputStream());
                ObjectInputStream in = new ObjectInputStream(s.getInputStream());
                outStream.writeObject(reqUsers);

                String[] receiveUsers = (String[])in.readObject();
                for(int i = 0; i < receiveUsers.length; i++){
                    this.model.getUsersList().add(receiveUsers[i]);
                }
            } finally {
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
    }

    public void close(){
        try {
            this.notify.interrupt();
        }catch (NullPointerException e){}
    }

    public boolean checkThread(){
        return this.notify.isInterrupted();
    }
}
