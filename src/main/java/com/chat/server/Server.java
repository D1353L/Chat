package com.chat.server;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.util.ArrayList;
import org.json.simple.JSONObject;
import org.json.simple.*;
@SuppressWarnings("unchecked")


class Server extends Thread
{
    
    final static int port=5196;
    static ArrayList<ClientInstance> clients=new ArrayList<ClientInstance>();
    static PostgreSQLJDBC db = new PostgreSQLJDBC();
    static int threads=0;

    public static void main(String args[])
    {
        ServerSocket server=null;
        try
        {

            server = new ServerSocket(port);

            System.out.println("server is started");
            

            // ожидание клиента
            while(true)
            {
                // после подключения клиента, добавляется в массив и выделяется отдельный поток
                clients.add(new ClientInstance(threads, server.accept()));
                threads++;
                System.out.println("Client - "+threads);
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

   
    
    public static void DataSort(ClientInstance client, JSONObject fromClient, PrintWriter out)
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
            	if("all".equals(fromClient.get("to")))
            	{
            		for(ClientInstance item: Server.clients)
            		{
            			item.Write(fromClient);
            		}
            	}
            	else
            	{
            		for(ClientInstance item: Server.clients)
            		{
            			if(item.login.equals(fromClient.get("to")))
            			{
            				item.Write(fromClient);
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
        
        System.out.println(login+'\n'+pass);
        
        JSONObject request = new JSONObject();
        request.put("type", "confirmation");
        request.put("name", login);
        
        if(db.IsCorrectCredentials(login, pass))
        {
        	client.login = login;
            request.put("isCorrectCredentials", "true");
            client.Write(request);
            
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
            
            JSONObject connections = new JSONObject();
            JSONArray users = new JSONArray();
            JSONObject newClient = new JSONObject();
                
            for(ClientInstance item: Server.clients)
                users.add(item.login);
              
                connections.put("type", "connections");
                connections.put("users", users);
                newClient.put("type", "newClient");
                newClient.put("name", login);
                
                for(ClientInstance item: Server.clients)
                	if(!item.login.equals(client.login))
                		item.Write(newClient);
                    
                try {
                	Thread.sleep(1200);
                }catch(InterruptedException ex){Thread.currentThread().interrupt();}
                    
                client.Write(connections);
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
}