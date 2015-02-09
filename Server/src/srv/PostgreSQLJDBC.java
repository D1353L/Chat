package srv;
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
	         c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/testdb","postgres", "admin123");
	      } catch (Exception e) {
	         e.printStackTrace();
	         System.err.println(e.getClass().getName()+": "+e.getMessage());
	         System.exit(0);
	      }
	      System.out.println("Opened database successfully");
	   }
	   
	   public static void AddNewUser(String username, String pass)
	   {
		   try {
			   if(!IsUserExist(username)){
				   stmt = c.createStatement();
				   String sql = "INSERT INTO users (user_name,user_pass) VALUES (username, pass);";
				   stmt.executeUpdate(sql);
				   stmt.close();
				   c.commit();
			   }
			   else
				   throw new Exception("User "+username+" already exist");
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); System.exit(0);}
	   }
	   
	   public static boolean IsUserExist(String username)
	   {
		   try {
			   stmt = c.createStatement();
			   ResultSet rs = stmt.executeQuery( "SELECT user_name FROM users;" );
			   while (rs.next()){
				   String  name = rs.getString("user_name");
				   if(name.equals(username)){
					   rs.close();
					   stmt.close();
					   return true;
				   }
			   }
			   return false;
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); System.exit(0); return false;}
	   }
	   
	   public static boolean IsCorrectCredentials(String username, String pass)
	   {
		   try {
			   if(IsUserExist(username)){
				   stmt = c.createStatement();
				   ResultSet rs = stmt.executeQuery( "SELECT user_name FROM users;" );
				   String  name = rs.getString("user_name");
				   String password = rs.getString("user_pass");
				   
				   if(name.equals(username) && pass.equals(password)){
					   rs.close();
					   stmt.close();
					   return true;
				   }
				   else{
					   rs.close();
					   stmt.close();
					   return false;
				   }
			   }
			   else throw new Exception("User "+username+" not exist");
		   }catch(Exception e){System.err.println( e.getClass().getName()+": "+ e.getMessage() ); System.exit(0); return false;} 
	   }
	   
}