package com.chat.server;

import org.json.simple.*;
import java.util.HashMap;
import java.util.ArrayList;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.java_websocket.WebSocket;

import java.net.InetSocketAddress;

import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

class Server extends WebSocketServer
{
	private HashMap<WebSocket, String> clients = new HashMap<WebSocket, String>();

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
        		System.out.println(String.format("To"+conn.getRemoteSocketAddress()+"{\type\": \"lostClient\", \"name\": \"%s\"}\r\n", clients.get(conn)));
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
        System.err.println("an error occured on connection " + conn.getRemoteSocketAddress()  + ":" + ex);
    }
    
    public void DataSort(WebSocket client, JSONObject fromClient)
    {
        try
        {
            if("userdata".equals(fromClient.get("type")))
            	LogIn(client, fromClient);
            
            else if("message".equals(fromClient.get("type")))
            {
            	if("all".equals(fromClient.get("to")))
            	{
            		for (WebSocket cl : clients.keySet()){
            			System.out.println("To "+cl.getRemoteSocketAddress()+" "+fromClient.toString());
            			cl.send(fromClient.toString());
            		}
            	}
            	else
            	{
            		for (WebSocket cl : clients.keySet())
                    	if(clients.get(cl).equals(fromClient.get("to")))
                    	{
                    		System.out.println("To "+cl.getRemoteSocketAddress()+" "+fromClient.toString());
                    		System.out.println("To "+client.getRemoteSocketAddress()+" "+fromClient.toString());
                    		cl.send(fromClient.toString());
                    		client.send(fromClient.toString());
                    		break;
                    	}
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
        
        if(("admin".equals(login) && "123".equals(pass)) || ("nik".equals(login) && "1".equals(pass)) || ("nik2".equals(login) && "1".equals(pass)))
        {
        	System.out.println("To "+client.getRemoteSocketAddress()+"{\"type\":\"confirmation\",\"isCorrectCredentials\":\"true\"}\r\n");
            client.send(String.format("{\"type\":\"confirmation\",\"isCorrectCredentials\":\"true\",\"name\":\"%s\"}\r\n", login));
            
            try {
                Thread.sleep(1200);
            }catch(InterruptedException ex){Thread.currentThread().interrupt();}
            
            for (WebSocket cl : clients.keySet()){
            	System.out.println(String.format("To "+client.getRemoteSocketAddress()+"{\"type\": \"newClient\", \"name\": \"%s\"}\r\n", login));
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
    
    public static void main(String[] args) {
        String host = "localhost";
        int port = 5168;

        WebSocketServer server = new Server(new InetSocketAddress(host, port));
        server.run();
    }
}