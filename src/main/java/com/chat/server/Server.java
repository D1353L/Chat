package com.chat.server;

import org.json.simple.*;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.java_websocket.WebSocket;

import java.net.InetSocketAddress;

import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

class Server extends WebSocketServer
{

    public Server(InetSocketAddress address) {
        super(address);
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        System.out.println("new connection to " + conn.getRemoteSocketAddress());
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        System.out.println("closed " + conn.getRemoteSocketAddress() + " with exit code " + code + " additional info: " + reason);
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
    	JSONParser parser=new JSONParser();
    	try{
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

            	}
            	else
            	{
            		
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
        String login=(String)json.get("login"), pass=(String)json.get("pass");
        
        System.out.println(login+'\n'+pass);
        
        if(("admin".equals(login) && "123".equals(pass)) || ("nik".equals(login) && "1".equals(pass)) || ("nik2".equals(login) && "1".equals(pass)))
        {
            client.send("{\"type\":\"confirmation\",\"isCorrectCredentials\":\"true\"}\r\n");
        }
        else
        {
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