package com.chat.server;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.postgresql.util.PSQLException;

public class PostgreSQLJDBC {
	
	static Connection c = null;
	static PreparedStatement stmt = null;
	
	   public PostgreSQLJDBC(String DB_URL, String DB_USERNAME, String DB_PASS) {
	      try {
	         Class.forName("org.postgresql.Driver");

	         c = DriverManager.getConnection("jdbc:postgresql://"+DB_URL+"/postgres", DB_USERNAME, DB_PASS);
	         
	         try{
	        	 stmt = c.prepareStatement("CREATE DATABASE chatdb");
	        	 stmt.executeUpdate();
	         }catch(PSQLException e){}
	         
	         
	         c = DriverManager.getConnection("jdbc:postgresql://"+DB_URL+"/chatdb", DB_USERNAME, DB_PASS);
	         System.out.println("Connected to DB");
	         
	         c.setAutoCommit(true);
	         
	         try{
	        	 stmt = c.prepareStatement("CREATE TABLE users (login text NOT NULL, email text, password text, first_name text, second_name text, \"position\" text, CONSTRAINT \"Plogin\" PRIMARY KEY (login)) WITH (OIDS=FALSE);");
	        	 stmt.executeUpdate();
	        	 System.out.println("Table users is created");
	         }catch(PSQLException e){}
	         
	         try{
	        	 stmt = c.prepareStatement("CREATE TABLE messages (sender text NOT NULL, receiver text NOT NULL, message text, id serial NOT NULL, CONSTRAINT \"pId\" PRIMARY KEY (id), CONSTRAINT \"fReceiver\" FOREIGN KEY (receiver) REFERENCES users (login) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION, CONSTRAINT \"fSender\" FOREIGN KEY (sender) REFERENCES users (login) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION) WITH ( OIDS=FALSE);");
	        	 stmt.executeUpdate();
	        	 System.out.println("Table messages is created");
	         }catch(PSQLException e){}
	         
	         try{
	        	 stmt = c.prepareStatement("CREATE INDEX \"fki_fReceiver\" ON messages USING btree (receiver COLLATE pg_catalog.\"default\"); CREATE INDEX \"fki_fSender\" ON messages USING btree (sender COLLATE pg_catalog.\"default\");");
	        	 stmt.executeUpdate();
	        	 System.out.println("Indexes for table messages are created");
	         }catch(PSQLException e){}
	         
	      } catch (Exception e) {
	         e.printStackTrace();
	         System.err.println(e.getClass().getName()+": "+e.getMessage());
	         System.exit(0);
	      }
	      
	   }
	   
	   public String AddNewUser(String login, String email, String pass, String fName, String sName, String position)
	   {
		   try {
				   String sql = String.format("INSERT INTO users VALUES ('%s', '%s', '%s', '%s', '%s', '%s');", login, email, pass, fName, sName, position);
				   stmt = c.prepareStatement(sql);
				   stmt.executeUpdate();
				   stmt.close();
				   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public boolean IsUserExist(String username)
	   {
		   try {
			   stmt = c.prepareStatement("SELECT login FROM users;");
			   ResultSet rs = stmt.executeQuery();
			   while (rs.next()){
				   String  name = rs.getString("login");
				   if(name.equals(username)){
					   rs.close();
					   stmt.close();
					   return true;
				   }
			   }
			   return false;
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return false;}
	   }
	   
	   public boolean IsEmailExist(String email)
	   {
		   try {
			   stmt = c.prepareStatement("SELECT email FROM users;");
			   ResultSet rs = stmt.executeQuery();
			   while (rs.next()){
				   String  em = rs.getString("email");
				   if(em.equals(email)){
					   rs.close();
					   stmt.close();
					   return true;
				   }
			   }
			   return false;
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return false;}
	   }
	   
	   public boolean IsCorrectCredentials(String username, String pass)
	   {
		   try {
			   if(IsUserExist(username)){
				   stmt = c.prepareStatement("SELECT * FROM users WHERE login = '"+username+"';");
				   ResultSet rs = stmt.executeQuery();
				   
				   while (rs.next()){
					   String  name = rs.getString("login");
					   String password = rs.getString("password");
					   
					   if(name.equals(username) && pass.equals(password)){
						   rs.close();
						   stmt.close();
						   return true;
					   }
				   }
				   rs.close();
				   stmt.close();
				   return false;
			   }
			   else throw new Exception("User "+username+" not exist");
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return false;} 
	   }
	   
	   public String getEmail(String login)
	   {
		   try {
			   stmt = c.prepareStatement("SELECT * FROM users WHERE login = '"+login+"';");
			   ResultSet rs = stmt.executeQuery();
		   
			   while (rs.next()){
				   String email = rs.getString("email");
				   rs.close();
				   stmt.close();
				   return email;   
			   }
			   rs.close();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return "";}
	   }
	   
	   public String getFname(String login)
	   {
		   try {
			   stmt = c.prepareStatement("SELECT * FROM users WHERE login = '"+login+"';");
			   ResultSet rs = stmt.executeQuery();
		   
			   while (rs.next()){
				   String fName = rs.getString("first_name");
				   rs.close();
				   stmt.close();
				   return fName;	   
			   }
			   rs.close();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return "";}
	   }
	   
	   public String getSName(String login)
	   {
		   try {
			   stmt = c.prepareStatement("SELECT * FROM users WHERE login = '"+login+"';");
			   ResultSet rs = stmt.executeQuery();
		   
			   while (rs.next()){
				   String sName = rs.getString("second_name");
				   rs.close();
				   stmt.close();
				   return sName;	   
			   }
			   rs.close();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return "";}
	   }
	   
	   public String getPosition(String login)
	   {
		   try {
			   stmt = c.prepareStatement("SELECT * FROM users WHERE login = '"+login+"';");
			   ResultSet rs = stmt.executeQuery();
		   
			   while (rs.next()){
				   String position = rs.getString("position");
				   rs.close();
				   stmt.close();
				   return position; 
			   }
			   rs.close();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return "";}
	   }
	   
	   public String setEmail(String login, String email)
	   {
		   try {
			   String sql = String.format("UPDATE users SET email = '%s' WHERE login = '%s';", email, login);
			   stmt = c.prepareStatement(sql);
			   stmt.executeUpdate();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setPassword(String login, String pass)
	   {
		   try {
			   String sql = String.format("UPDATE users SET password = '%s' WHERE login = '%s';", pass, login);
			   stmt = c.prepareStatement(sql);
			   stmt.executeUpdate();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setFName(String login, String fName)
	   {
		   try {
			   String sql = String.format("UPDATE users SET first_name = '%s' WHERE login = '%s';", fName, login);
			   stmt = c.prepareStatement(sql);
			   stmt.executeUpdate();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setSName(String login, String sName)
	   {
		   try {
			   String sql = String.format("UPDATE users SET second_name = '%s' WHERE login = '%s';", sName, login);
			   stmt = c.prepareStatement(sql);
			   stmt.executeUpdate();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setPosition(String login, String pos)
	   {
		   try {
			   String sql = String.format("UPDATE users SET position = '%s' WHERE login = '%s';", pos, login);
			   stmt = c.prepareStatement(sql);
			   stmt.executeUpdate();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String addMessage(String sender, String receiver, String message)
	   {
		   try {
			   String sql = String.format("INSERT INTO messages VALUES ('%s', '%s', '%s');", sender, receiver, message);
			   stmt = c.prepareStatement(sql);
			   stmt.executeUpdate();
			   stmt.close();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String getMessages(String user1, String user2)
	   {
		   try {
			   stmt = c.prepareStatement("SELECT message FROM messages WHERE (sender = '"+user1+"' AND receiver = '"+user2+"') OR (sender = '"+user2+"' AND receiver = '"+user1+"');");
			   ResultSet rs = stmt.executeQuery();
			   
			   String msg = "";
			   while (rs.next()) msg = msg+rs.getString("message");
			   
			   rs.close();
			   stmt.close();
			   return msg;
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return "";}
	   }
	   
}