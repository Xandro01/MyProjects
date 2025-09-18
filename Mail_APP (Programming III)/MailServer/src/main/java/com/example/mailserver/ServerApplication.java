package com.example.mailserver;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

import java.io.IOException;

public class ServerApplication extends Application {
    @Override
    public void start(Stage stage) throws IOException {
        FXMLLoader fxmlLoader = new FXMLLoader(ServerApplication.class.getResource("mail-server-view.fxml"));
        Scene scene = new Scene(fxmlLoader.load(), 600, 410);
        stage.setTitle("Server");

        Image image = new Image(ServerApplication.class.getResourceAsStream("/com/example/Icon/Server.png"));
        stage.getIcons().add(image);

        stage.setScene(scene);
        stage.show();

        ServerController ServerController = fxmlLoader.getController();
        ServerController.initModel();
        stage.setOnCloseRequest(event -> {
            ServerController.close();
            System.exit(0);
        } );
    }

    public static void main(String[] args) {
        launch();
    }
}