package com.example.mailserver;

import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class StartServerTask implements Runnable{
    ServerController controller;
    ReadWriteLock rwLock;
    public StartServerTask(ServerController controller){
        this.controller = controller;
        this.rwLock = new ReentrantReadWriteLock();
    }

    @Override
    public void run() {
        ExecutorService exec = Executors.newFixedThreadPool(5);
        try {
            ServerSocket s = new ServerSocket(9199);
            while (!(this.controller.checkThread())) {
                Socket incoming = s.accept();
                exec.execute(new Task(incoming, this.controller, this.rwLock));
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
