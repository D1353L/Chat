package com.chat.server;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.ResultSet;

public class PostgreSQLJDBC {
	
	static Connection c = null;
	static Statement stmt = null;
	
	   public PostgreSQLJDBC() {
	      try {
	         Class.forName("org.postgresql.Driver");
	         c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/ChatDB","postgres", "admin123");
	         c.setAutoCommit(false);
	      } catch (Exception e) {
	         e.printStackTrace();
	         System.err.println(e.getClass().getName()+": "+e.getMessage());
	         System.exit(0);
	      }
	      System.out.println("Connected to DB");
	   }
	   
	   public String AddNewUser(String login, String email, String pass, String fName, String sName, String position)
	   {
		   try {
				   stmt = c.createStatement();
				   String sql = String.format("INSERT INTO users VALUES ('%s', '%s', '%s', '%s', '%s', '%s');", login, email, pass, fName, sName, position);
				   stmt.executeUpdate(sql);
				   stmt.close();
				   c.commit();
				   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public boolean IsUserExist(String username)
	   {
		   try {
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT login FROM users;" );
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
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT email FROM users;" );
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
				   stmt = c.createStatement();
				   ResultSet rs = stmt.executeQuery( "SELECT * FROM users WHERE login = '"+username+"';" );
				   
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
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT * FROM users WHERE login = '"+login+"';" );
		   
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
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT * FROM users WHERE login = '"+login+"';" );
		   
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
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT * FROM users WHERE login = '"+login+"';" );
		   
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
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT * FROM users WHERE login = '"+login+"';" );
		   
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
			   stmt = c.createStatement();
			   String sql = String.format("UPDATE users SET email = '%s' WHERE login = '%s';", email, login);
			   stmt.executeUpdate(sql);
			   stmt.close();
			   c.commit();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setPassword(String login, String pass)
	   {
		   try {
			   stmt = c.createStatement();
			   String sql = String.format("UPDATE users SET password = '%s' WHERE login = '%s';", pass, login);
			   stmt.executeUpdate(sql);
			   stmt.close();
			   c.commit();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setFName(String login, String fName)
	   {
		   try {
			   stmt = c.createStatement();
			   String sql = String.format("UPDATE users SET first_name = '%s' WHERE login = '%s';", fName, login);
			   stmt.executeUpdate(sql);
			   stmt.close();
			   c.commit();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setSName(String login, String sName)
	   {
		   try {
			   stmt = c.createStatement();
			   String sql = String.format("UPDATE users SET second_name = '%s' WHERE login = '%s';", sName, login);
			   stmt.executeUpdate(sql);
			   stmt.close();
			   c.commit();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String setPosition(String login, String pos)
	   {
		   try {
			   stmt = c.createStatement();
			   String sql = String.format("UPDATE users SET position = '%s' WHERE login = '%s';", pos, login);
			   stmt.executeUpdate(sql);
			   stmt.close();
			   c.commit();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String addMessage(String sender, String receiver, String message)
	   {
		   try {
			   stmt = c.createStatement();
			   String sql = String.format("INSERT INTO messages VALUES ('%s', '%s', '%s');", sender, receiver, message);
			   stmt.executeUpdate(sql);
			   stmt.close();
			   c.commit();
			   return "";
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage()); return e.getMessage();}
	   }
	   
	   public String getMessages(String user1, String user2)
	   {
		   try {
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT message FROM messages WHERE (sender = '"+user1+"' AND receiver = '"+user2+"') OR (sender = '"+user2+"' AND receiver = '"+user1+"');" );
			   
			   String msg = "";
			   while (rs.next()) msg = msg+rs.getString("message");
			   
			   rs.close();
			   stmt.close();
			   return msg;
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); return "";}
	   }
	   
}