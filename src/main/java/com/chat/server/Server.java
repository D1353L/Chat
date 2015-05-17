package com.chat.server;

import org.json.simple.*;

import java.util.HashMap;
import java.util.ArrayList;

import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.java_websocket.WebSocket;
import org.java_websocket.WebSocketImpl;

import java.net.InetSocketAddress;

import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

class Server extends WebSocketServer
{
	private HashMap<WebSocket, String> clients = new HashMap<WebSocket, String>();
	private PostgreSQLJDBC db = new PostgreSQLJDBC();

    public Server(InetSocketAddress address) {
    	super(address);
    	System.out.println("server started");
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        System.out.println("new connection to " + conn.getRemoteSocketAddress());
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        System.out.println("closed " + conn.getRemoteSocketAddress() + " with exit code " + code + " additional info: " + reason);
        
        for (WebSocket client : clients.keySet()) {
        	if(client!=conn){
        		System.out.println(String.format("To"+client.getRemoteSocketAddress()+"{\"type\": \"lostClient\", \"name\": \"%s\"}\r\n", clients.get(conn)));
        		client.send(String.format("{\"type\": \"lostClient\", \"name\": \"%s\"}\r\n", clients.get(conn)));
        	}
        }
        clients.remove(conn);
            
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
    	JSONParser parser=new JSONParser();
    	try{
    		System.out.println("From "+conn.getRemoteSocketAddress()+" "+message);
    		DataSort(conn, (JSONObject)parser.parse(message));
    	}catch(ParseException pe){System.err.println("Parse exception from "+conn.getRemoteSocketAddress()+": "+pe);}
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
    	ex.printStackTrace();
    }
    
    public void DataSort(WebSocket client, JSONObject fromClient)
    {
        try
        {
            if("userdata".equals(fromClient.get("type")))
            	LogIn(client, fromClient);
            
            else if("regRequest".equals(fromClient.get("type")))
            	Registration(client, (String)fromClient.get("login"), (String)fromClient.get("email"), (String)fromClient.get("pass"), (String)fromClient.get("fName"), (String)fromClient.get("sName"), (String)fromClient.get("position"));
            
            else if("changeUserData".equals(fromClient.get("type")))
            	ChangeUserData(client, (String)fromClient.get("login"), (String)fromClient.get("email"), (String)fromClient.get("pass"), (String)fromClient.get("fName"), (String)fromClient.get("sName"), (String)fromClient.get("position"));
            	
            else if("message".equals(fromClient.get("type")))
            {
            	for (WebSocket cl : clients.keySet())
            		if(clients.get(cl).equals(fromClient.get("to")))
                    {
                    	System.out.println("To "+cl.getRemoteSocketAddress()+" "+fromClient.toString());
                    	cl.send(fromClient.toString());
                    	break;
                    }
            }
            else
            {
                throw new Exception("Invalid message type");
            }
        }
        catch(Exception e)
        {System.out.println("DataSort - init error: "+e);}
    }
    
    private void LogIn(WebSocket client, JSONObject json)
    {
        String login=(String)json.get("login"),
        		pass=(String)json.get("pass");
        
        if(db.IsCorrectCredentials(login, pass))
        {
        	System.out.println("To "+client.getRemoteSocketAddress()+"{\"type\":\"confirmation\",\"isCorrectCredentials\":\"true\"}\r\n");
            client.send(String.format("{\"type\":\"confirmation\",\"isCorrectCredentials\":\"true\",\"name\":\"%s\"}\r\n", login));
            
            try {
                Thread.sleep(1200);
            }catch(InterruptedException ex){Thread.currentThread().interrupt();}
            
            client.send(String.format("{\"type\":\"userData\",\"login\":\"%s\",\"email\":\"%s\",\"fName\":\"%s\",\"sName\":\"%s\",\"position\":\"%s\"}\r\n", login, db.getEmail(login), db.getFname(login), db.getSName(login), db.getPosition(login)));
            
            try {
                Thread.sleep(1200);
            }catch(InterruptedException ex){Thread.currentThread().interrupt();}
            
            for (WebSocket cl : clients.keySet()){
            	System.out.println(String.format("To "+cl.getRemoteSocketAddress()+"{\"type\": \"newClient\", \"name\": \"%s\"}\r\n", login));
            	cl.send(String.format("{\"type\": \"newClient\", \"name\": \"%s\"}\r\n", login));
            }

            ArrayList<String> users=new ArrayList<String>();
            for (WebSocket cl : clients.keySet())
            	users.add(clients.get(cl));
            
            System.out.println(String.format("To "+client.getRemoteSocketAddress()+"{\"type\":\"connections\",\"users\":\"%s\"}\r\n", users.toString()));
            client.send(String.format("{\"type\":\"connections\",\"users\":\"%s\"}\r\n", users.toString()));
            
            clients.put(client, login);
        }
        else
        {
        	System.out.println("To "+client.getRemoteSocketAddress()+"{\"type\":\"confirmation\",\"isCorrectCredentials\":\"false\"}\r\n");
            client.send("{\"type\":\"confirmation\",\"isCorrectCredentials\":\"false\"}\r\n");
        }
    }
    
    private void Registration(WebSocket client, String login, String email, String pass, String fName, String sName, String position)
    {
    	if(db.IsUserExist(login))
    		client.send("{\"type\":\"regResponse\",\"conflictedData\":\"login\",\"exception\":\"\"}\r\n");
    	
    	else if(db.IsEmailExist(login))
    		client.send("{\"type\":\"regResponse\",\"conflictedData\":\"email\",\"exception\":\"\"}\r\n");
    	
    	else{
    		String dbResp = db.AddNewUser(login, email, pass, fName, sName, position);
    		client.send(String.format("{\"type\":\"regResponse\",\"conflictedData\":\"\",\"exception\":\"%s\"}\r\n", dbResp));
    	}
    }
    
    private void ChangeUserData(WebSocket client, String login, String email, String pass, String fName, String sName, String position)
    {
    	db.setEmail(login, email);
    	db.setFName(login, fName);
    	db.setSName(login, sName);
    	db.setPosition(login, position);
    	if(pass != "") db.setPassword(login, pass);
    	client.send(String.format("{\"type\":\"userData\",\"login\":\"%s\",\"email\":\"%s\",\"fName\":\"%s\",\"sName\":\"%s\",\"position\":\"%s\"}\r\n", login, db.getEmail(login), db.getFname(login), db.getSName(login), db.getPosition(login)));
    }
    
    public static void main(String[] args) {
        String host = "localhost";
        int port = 5168;
        WebSocketImpl.DEBUG = true;
        WebSocketServer server = new Server(new InetSocketAddress(host, port));
        server.run();
    }
}