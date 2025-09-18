package com.example.mailserver;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import java.io.*;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.security.Timestamp;
import java.util.Date;
import java.util.Iterator;
import java.util.Scanner;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;

public class Task implements Runnable{
    private Socket socket;
    private ServerController serverController;
    private Lock readLock;
    private Lock writeLock;

    public Task(Socket inc, ServerController serverController, ReadWriteLock lock){
        this.socket = inc;
        this.serverController = serverController;
        this.readLock = lock.readLock();
        this.writeLock = lock.writeLock();
    }

    @Override
    public void run() {
        try {
            try {
                ObjectOutputStream outStream = new ObjectOutputStream(this.socket.getOutputStream());
                ObjectInputStream in = new ObjectInputStream(this.socket.getInputStream());
                Date date = new Date();
                boolean next = true;
                while (next) {
                    try {
                        String[][] data = (String[][]) in.readObject();
                        switch (data[0][0]) {
                            case Util.RESET_NOTIFY:
                                handleRESETNOTIFY(data[0][1], outStream);
                                this.serverController.setArrayListLog("Time:" + date + ", " + data[0][1] + " " + "ha aggiornato la sua casella di posta");
                                break;
                            case Util.HAS_NOTIFY:
                                handleNOTIFY(data[0][1], outStream);
                                break;
                            case Util.SEND_ALL_USER:
                                handleSNDALLUSR(outStream);
                                this.serverController.setArrayListLog("Time:" + date + ", " + "invio al client la lista degli utenti");
                                break;
                            case Util.REQUEST_ACCOUNT:
                                handleRQSTACC(outStream, data[0][1]);
                                this.serverController.setArrayListLog("Time:" + date + ", " + data[0][1] + " " + "ha richiesto la sua casella di posta");
                                break;
                            case Util.SEND_MSG:
                                handleSNDMSG(outStream, data);
                                this.serverController.setArrayListLog("Time:" + date + ", " + data[0][1] + " " + "ha mandato un messaggio a" + " " + data[0][2]);
                                break;
                            case Util.DELEM:
                                handleDLEML(outStream, data);
                                break;
                        }
                    }catch (EOFException e){
                        next = false;
                    }catch(SocketException s){

                    }
                }
            }finally {
                this.socket.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void handleRESETNOTIFY(String accountToReset, ObjectOutputStream out) {
        JSONParser parser = new JSONParser();

        writeLock.lock();
        try {
            Object obj = parser.parse(new FileReader("MailServer/src/account.json"));
            JSONObject jsonObject = (JSONObject) obj;
            JSONArray listOfUsers = (JSONArray) jsonObject.get("ListOfUsers");

            for(int i = 0; i < listOfUsers.size(); i++){
                JSONObject item = (JSONObject) listOfUsers.get(i);
                if(accountToReset.compareTo(item.get("name").toString()) == 0){
                    item.replace("hasNotify", false);
                    break;
                }
            }
            jsonObject.replace("ListOfUsers", listOfUsers);
            FileWriter account = new FileWriter("MailServer/src/account.json");
            account.write(jsonObject.toJSONString());
            account.flush();

            out.writeObject(true);
        } catch (Exception e) {
            e.printStackTrace();
        }
        writeLock.unlock();
    }

    private void handleSNDALLUSR(ObjectOutputStream out){
        JSONParser parser = new JSONParser();

        readLock.lock();
        try {
            Object obj = parser.parse(new FileReader("MailServer/src/account.json"));
            JSONObject jsonObject = (JSONObject) obj;
            JSONArray listOfUsers = (JSONArray) jsonObject.get("ListOfUsers");

            String[] users = new String[listOfUsers.size()];
            for(int i = 0; i < listOfUsers.size(); i++){
                JSONObject item = (JSONObject) listOfUsers.get(i);
                users[i] = item.get("name").toString();
            }
            out.writeObject(users);
        } catch (Exception e) {
            e.printStackTrace();
        }
        readLock.unlock();
    }

    private void handleRQSTACC(ObjectOutputStream out, String account){
        JSONParser parser = new JSONParser();

        writeLock.lock();
        try {
            Object obj = parser.parse(new FileReader("MailServer/src/account.json"));
            JSONObject jsonObject = (JSONObject) obj;
            JSONArray listOfUsers = (JSONArray) jsonObject.get("ListOfUsers");

            String[][] email = new String[0][];
            for (int searchAccount = 0; searchAccount < listOfUsers.size(); searchAccount++) {
                JSONObject item = (JSONObject) listOfUsers.get(searchAccount);
                String currentAccount = item.get("name").toString();
                if ((currentAccount.compareTo(account)) == 0) {
                    item.replace("hasNotify", false);
                    JSONArray emailList = (JSONArray) item.get("emailList");
                    JSONArray emailListDelete = (JSONArray) item.get("emailListDelete");
                    email = new String[((emailList.size() + 1))][7];

                    email[0][0] = Boolean.toString((boolean) item.get("hasNotify"));

                    for (int i = 0; i < emailList.size(); i++) {
                        JSONObject element = (JSONObject) emailList.get(i);

                        String data = (String) element.get("data");
                        String subject = (String) element.get("subject");
                        String from = (String) element.get("from");
                        String to = (String) element.get("to");
                        String content = (String) element.get("content");
                        String ora = (String) element.get("ora");
                        email[i+1][0] = data;
                        email[i+1][1] = subject;
                        email[i+1][2] = from;
                        email[i+1][3] = to;
                        email[i+1][4] = content;
                        email[i+1][5] = ora;

                        if(!(emailListDelete.contains(element))) {
                            email[i+1][6] = "false";
                        }else{
                            email[i+1][6] = "true";
                        }
                    }
                    break;
                }
            }
            jsonObject.replace("ListOfUsers", listOfUsers);

            FileWriter accountForWrite = new FileWriter("MailServer/src/account.json");
            accountForWrite.write(jsonObject.toJSONString());
            accountForWrite.flush();

            out.writeObject(email);
        } catch (Exception e) {
            e.printStackTrace();
        }
        writeLock.unlock();
    }

    private void handleSNDMSG(ObjectOutputStream out, String[][] data){
        JSONParser parser = new JSONParser();
        int flag = 0;

        writeLock.lock();
        try {

            Object obj = parser.parse(new FileReader("MailServer/src/account.json"));
            JSONObject jsonObject = (JSONObject) obj;
            JSONArray listOfUsers = (JSONArray) jsonObject.get("ListOfUsers");

            int from = 0;
            String userFrom = data[0][1];
            String[] userTo = data[0][2].split(", ");
            int[] to = new int[userTo.length];
            for(int j = 0; j < to.length; j++) {
                for (int i = 0; i < listOfUsers.size(); i++) {
                    JSONObject item = (JSONObject) listOfUsers.get(i);
                    if ((userTo[j].compareTo(item.get("name").toString())) == 0) {
                        to[j] = i;
                        flag++;
                    }
                    if ((userFrom.compareTo(item.get("name").toString())) == 0 && from == 0) {
                        from = i;
                    }
                }
            }
            Boolean b = flag == to.length;
            if(b) {
                JSONObject newEmail = new JSONObject();
                newEmail.put("from", data[0][1]);
                newEmail.put("to", data[0][2]);
                newEmail.put("subject", data[0][3]);
                newEmail.put("content", data[0][4]);
                newEmail.put("ora", data[0][5]);
                newEmail.put("data", data[0][6]);

                JSONObject addNewEmailFrom = (JSONObject) listOfUsers.get(from);
                JSONArray emailListFrom = (JSONArray) addNewEmailFrom.get("emailList");
                emailListFrom.add(newEmail);

                for(int j = 0; j < to.length; j++) {
                    JSONObject addNewEmailTo = (JSONObject) listOfUsers.get(to[j]);
                    JSONArray emailListTo = (JSONArray) addNewEmailTo.get("emailList");
                    emailListTo.add(newEmail);
                    addNewEmailTo.replace("hasNotify", true);
                }

                jsonObject.replace("ListOfUsers", listOfUsers);

                FileWriter account = new FileWriter("MailServer/src/account.json");
                account.write(jsonObject.toJSONString());
                account.flush();
            }

            out.writeObject(b);
        } catch (Exception e) {
            e.printStackTrace();
        }
        writeLock.unlock();
    }

    private void handleDLEML(ObjectOutputStream out, String[][] data){
        JSONParser parser = new JSONParser();

        writeLock.lock();
        try {
            Object obj = parser.parse(new FileReader("MailServer/src/account.json"));
            JSONObject jsonObject = (JSONObject) obj;
            JSONArray listOfUsers = (JSONArray) jsonObject.get("ListOfUsers");

            String user = data[0][1];
            int numOfEmailDelete = 0;
            for (int i = 0; i < listOfUsers.size(); i++) {
                JSONObject item = (JSONObject) listOfUsers.get(i);
                if((user.compareTo(item.get("name").toString())) == 0){
                    for(int j = 0; j < data.length; j++) {
                        JSONArray emailListDelete = (JSONArray) item.get("emailListDelete");
                        JSONObject newEmailDelete = new JSONObject();
                        newEmailDelete.put("from", data[j][2]);
                        newEmailDelete.put("to", data[j][3]);
                        newEmailDelete.put("subject", data[j][4]);
                        newEmailDelete.put("content", data[j][5]);
                        newEmailDelete.put("ora", data[j][6]);
                        newEmailDelete.put("data", data[j][7]);
                        if((data[j][8].compareTo("false")) == 0) {
                            emailListDelete.add(newEmailDelete);
                        }else if((data[j][8].compareTo("true")) == 0){
                            JSONArray emailList = (JSONArray) item.get("emailList");
                            emailList.remove(newEmailDelete);
                            emailListDelete.remove(newEmailDelete);
                            numOfEmailDelete++;
                        }else if((data[j][8].compareTo("ripristino")) == 0){
                            emailListDelete.remove(newEmailDelete);
                        }
                    }

                    if(numOfEmailDelete > 0) {
                        Date date = new Date();
                        this.serverController.setArrayListLog("Time:" + date + ", " + data[0][1] + " " + "ha eliminato definitivamente" + " " + numOfEmailDelete);
                    }

                    jsonObject.replace("ListOfUsers", listOfUsers);

                    FileWriter account = new FileWriter("MailServer/src/account.json");
                    account.write(jsonObject.toJSONString());
                    account.flush();
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        writeLock.unlock();
    }


    private void handleNOTIFY(String AccountToCheck, ObjectOutputStream out){
        JSONParser parser = new JSONParser();
        readLock.lock();
        try {
            Object obj = parser.parse(new FileReader("MailServer/src/account.json"));
            JSONObject jsonObject = (JSONObject) obj;
            JSONArray listOfUsers = (JSONArray) jsonObject.get("ListOfUsers");

            for(int i = 0; i < listOfUsers.size(); i++){
                JSONObject item = (JSONObject) listOfUsers.get(i);
                if(AccountToCheck.compareTo(item.get("name").toString()) == 0){
                    out.writeObject(item.get("hasNotify"));
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        readLock.unlock();
    }
}