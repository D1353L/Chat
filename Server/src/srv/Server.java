package srv;
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
            
            else if("message".equals(fromClient.get("type")))
                for(ClientInstance item: Server.clients)
                    item.Write(fromClient);
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
        
        if(("admin".equals(login) && "123".equals(pass)) || ("nik".equals(login) && "1".equals(pass)))
        {
            request.put("isCorrectCredentials", "true");
            client.Write(request);
            client.login=login;
                client.logged=true;
                
                JSONObject connections = new JSONObject();
                JSONArray users = new JSONArray();
                JSONObject newConnection = new JSONObject();
                
                for(ClientInstance item: Server.clients)
                    users.add(item.login);  
              
                connections.put("type", "connections");
                connections.put("users", users);
                
                for(ClientInstance item: Server.clients)
                {
                    if(!item.login.equals(login))
                    {
                        newConnection.put("type", "newConnection");
                        newConnection.put("login", login);
                        item.Write(newConnection);    
                    }
                    
                    try {
                        Thread.sleep(500);
                    }catch(InterruptedException ex){Thread.currentThread().interrupt();}
                    
                    item.Write(connections);
                }
        }
        else
        {
            request.put("isCorrectCredentials", "false");
            client.Write(request);
        }
    }
}