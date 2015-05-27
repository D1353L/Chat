package com.chat.server;
import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;
import org.json.simple.JSONObject;
import org.json.simple.*;
import java.util.*;
import java.text.*;

@SuppressWarnings("unchecked")


class Server extends Thread
{
    final static int port=5196;
    static ArrayList<ClientInstance> clients=new ArrayList<ClientInstance>();
    static PostgreSQLJDBC db = new PostgreSQLJDBC();

    public static void main(String args[])
    {
        ServerSocket server=null;
        try
        {
            server = new ServerSocket(port);
            System.out.println("server is started");

            //wait for client
            while(true)
            {
                //after connect, client is allocated to a separate thread
                clients.add(new ClientInstance(server.accept()));
                Thread.sleep(100);
            }
        }
        catch(Exception e)
        {
            System.out.println("main - init error: "+e);
            try
            {
                server.close();
            }catch(IOException io)
            {System.out.println("main - IOException: "+io);}
        }
    }
   
    //Method for sorting received data
    public static void DataSort(ClientInstance client, JSONObject fromClient)
    {
        try
        {
            if("userdata".equals(fromClient.get("type")))
                    LogIn(client, fromClient);
            
            else if("regRequest".equals(fromClient.get("type")))
            	Registration(client, (String)fromClient.get("login"), (String)fromClient.get("email"), (String)fromClient.get("pass"), (String)fromClient.get("fName"), (String)fromClient.get("sName"), (String)fromClient.get("position"));
            
            else if("changeUserData".equals(fromClient.get("type")))
            	ChangeUserData(client, (String)fromClient.get("login"), (String)fromClient.get("email"), (String)fromClient.get("pass"), (String)fromClient.get("fName"), (String)fromClient.get("sName"), (String)fromClient.get("position"));
            
            else if("status".equals(fromClient.get("type")))
            	ChangeStatus(client, (String)fromClient.get("status"));
            
            else if("getMessages".equals(fromClient.get("type")))
            	GetMessages(client, (String)fromClient.get("user"));
            	
            else if("message".equals(fromClient.get("type")))
            {
            	//Sending message to all clients
            	if("all".equals(fromClient.get("to")))
            	{
            		for(ClientInstance item: Server.clients)
            		{
            			item.Write(fromClient);
            		}
            	}
            	else
            	{
            		//Sending message to a separate client
            		for(ClientInstance item: Server.clients)
            		{
            			if(item.login.equals(fromClient.get("to")))
            			{
            				item.Write(fromClient);
            				
            				Date dNow = new Date();
            				SimpleDateFormat ft = new SimpleDateFormat("dd.M.yyyy HH:mm:ss");
            				db.addMessage(client.login, item.login, "["+ft.format(dNow)+"] "+client.login+": "+fromClient.get("msg").toString());

            				break;
            			}
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
    
    private static void LogIn(ClientInstance client, JSONObject json)
    {
        String login=(String)json.get("login"), pass=(String)json.get("pass");
        JSONObject request = new JSONObject();
        request.put("type", "confirmation");
        request.put("name", login);
        
        if(db.IsCorrectCredentials(login, pass))
        {
        	for(ClientInstance item: Server.clients)
        		if(item.login.equals(login))
        		{
        			request.put("isCorrectCredentials", "alreadyConnected");
        			client.Write(request);
        			return;
        		}
        	
        	System.out.println("User "+login+" connected");
        	client.login = login;
        	client.status = "online";
            request.put("isCorrectCredentials", "true");
            client.Write(request);
            
            //Sending user data from DB to client
            JSONObject userdata = new JSONObject();
            userdata.put("type", "userData");
            userdata.put("login", login);
            userdata.put("email",db.getEmail(login));
            userdata.put("fName",db.getFname(login));
            userdata.put("sName",db.getSName(login));
            userdata.put("position",db.getPosition(login));
            
            try {
            	Thread.sleep(1200);
            }catch(InterruptedException ex){Thread.currentThread().interrupt();}
            
            client.Write(userdata);

            //Sending list of connected (online and busy) users to client
            JSONObject connections = new JSONObject();
            JSONArray users = new JSONArray();
            JSONObject newClient = new JSONObject();
            
            for(ClientInstance item: Server.clients)
            	users.add(item.login+":"+item.status);

            connections.put("type", "connections");
            connections.put("users", users);
                   
            try {
                Thread.sleep(1200);
            }catch(InterruptedException ex){Thread.currentThread().interrupt();}
                    
            client.Write(connections);
            
            newClient.put("type", "newClient");
            newClient.put("name", client.login+":"+client.status);
            for(ClientInstance item: Server.clients)
            	if(!item.login.equals(client.login)) item.Write(newClient);
            
        }
        else
        {
            request.put("isCorrectCredentials", "false");
            client.Write(request);
        }
    }
    
    private static void Registration(ClientInstance client, String login, String email, String pass, String fName, String sName, String position)
    {
    	JSONObject regResp = new JSONObject();
    	regResp.put("type", "regResponse");
    	
    	if(db.IsUserExist(login)){
    		regResp.put("conflictedData", "login");
    		regResp.put("exception", "");
    	}
    	else if(db.IsEmailExist(login)){
    		regResp.put("conflictedData", "email");
    		regResp.put("exception", "");
    	}
    	else{
    		String dbResp = db.AddNewUser(login, email, pass, fName, sName, position);
    		regResp.put("conflictedData", "email");
    		regResp.put("exception", dbResp);
    	}
    	client.Write(regResp);
    }
    
    private static void ChangeUserData(ClientInstance client, String login, String email, String pass, String fName, String sName, String position)
    {
    	db.setEmail(login, email);
    	db.setFName(login, fName);
    	db.setSName(login, sName);
    	db.setPosition(login, position);
    	if(pass.compareTo(" ") > 0) db.setPassword(login, pass);
    	
    	JSONObject userdata = new JSONObject();
    	userdata.put("type", "userData");
        userdata.put("login", login);
        userdata.put("email",db.getEmail(login));
        userdata.put("fName",db.getFname(login));
        userdata.put("sName",db.getSName(login));
        userdata.put("position",db.getPosition(login));
    	client.Write(userdata);
    }
    
    public static void ChangeStatus(ClientInstance client, String status)
    {
    	JSONObject response = new JSONObject();
    	
    	if("online".equals(status))
    	{
    		response.put("type", "newClient");
    		if("offline".equals(client.status))
    			response.put("name", client.login+":"+status);
    		else response.put("name", client.login+":"+client.status);
    	}
    	else if("offline".equals(status))
    	{
    		response.put("type", "lostClient");
    		response.put("name", client.login+":"+client.status);
    	}
    	else if("busy".equals(status))
    	{
    		response.put("type", "busy");
    		response.put("name", client.login+":"+client.status);
    	}
    	client.status = status;
    	
    	for(ClientInstance item: Server.clients)
        	if(!item.login.equals(client.login)) item.Write(response);
    }
    
    public static void GetMessages(ClientInstance client, String user)
    {
    	JSONObject messages = new JSONObject();
    	messages.put("type", "messages");
    	messages.put("messages", db.getMessages(client.login, user));
    	messages.put("user", user);
    	client.Write(messages);
    }
}