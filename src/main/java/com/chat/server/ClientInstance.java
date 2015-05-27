package com.chat.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.SocketException;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;



class ClientInstance extends Thread
{
    Socket socket;
    String login;
    String status;
    BufferedReader in;
    PrintWriter out;
    
    public ClientInstance(Socket socket) throws IOException {
        this.socket = socket;
        this.login="";
        this.status="";
        
        in  = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
        out = new PrintWriter(this.socket.getOutputStream(),true);
        
        setDaemon(true);
        setPriority(NORM_PRIORITY);
        start();
        //control switches to the method run()
    }

    public void run()
    {
        try
        {
            String clientMsg="";
            JSONObject clientMsgJSON = new JSONObject();
            JSONParser parser=new JSONParser();
            
            //waiting for incoming message from current client
            while((clientMsg = in.readLine()) != null)
            {
                System.out.println("R "+this.login+"  "+clientMsg);
                clientMsgJSON = (JSONObject)parser.parse(clientMsg);
                Server.DataSort(this, clientMsgJSON);
            }
            
            socket.close();
            DisconnectThisUser();
        }
        catch(SocketException se)
        {
            try{
                socket.close();
                DisconnectThisUser();
            }catch(IOException io)
            {System.out.println("run - IOException: "+io);}
        }
        catch(Exception e)
        {System.out.println("run - error: "+e);}
               

    }
    
    public void DisconnectThisUser()
    {
        System.out.println("User "+this.login+" disconnected");      
        Server.ChangeStatus(this, "offline");
        Server.clients.remove(this);
    }
    
    public void Write(JSONObject json)
    {
        System.out.println("W "+this.login+"  "+json);
        out.println(json);
    }
}