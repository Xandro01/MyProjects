package com.example.mailclient;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

import java.io.IOException;
import java.util.HashMap;


public class ClientApplication extends Application {
    @Override
    public void start(Stage stage) throws IOException {
        FXMLLoader fxmlLoader = new FXMLLoader(ClientApplication.class.getResource("mail-client-view.fxml"));
        Scene scene = new Scene(fxmlLoader.load(), 700, 410);
        stage.setTitle("Client");

        Image image = new Image(ClientApplication.class.getResourceAsStream("/com/example/Icon/Client.png"));
        stage.getIcons().add(image);

        stage.setScene(scene);
        stage.show();

        HashMap<Email, String> hashMap = new HashMap<>();
        DataModel model = new DataModel(hashMap);
        ClientController ClientController = fxmlLoader.getController();
        ClientController.initModel(model);
        stage.setOnCloseRequest(event -> {
            ClientController.close();
            System.exit(0);
        } );
    }

    public static void main(String[] args) {
        launch();
    }
}
