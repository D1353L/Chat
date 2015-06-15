class ClientModel
  attr_accessor :socket, :serverMsg, :connections, :username, :email, :fName, :sName, :position 

  #server - <IP>:<Port>
  def self.connect(login, pass, server)
    begin  
      @socket = TCPSocket.new(server.split(':')[0], server.split(':')[1])
    rescue TypeError
      ClientController.wrongServer
      return
    rescue Errno::ECONNREFUSED  
      ClientController.serverNotResponse
      return
    end   
   
    userdataJSON = JSON.generate('type'=>'userdata', 'login' =>login, 'pass'=>pass)   
    @socket.puts Security.encrypt(userdataJSON)
    Thread.new do
      while(true)
        @serverMsg=@socket.recv(10000)
        self.data_sort(Security.decrypt(@serverMsg))
      end
    end
  end
  
  #server - <IP>:<Port>
  def self.registration(login, email, pass, fName, sName, pos, server)
    begin  
      @socket = TCPSocket.new(server.split(':')[0], server.split(':')[1])
    rescue TypeError
      ClientController.wrongServer
      return
    rescue Errno::ECONNREFUSED  
      ClientController.serverNotResponse 
      return 
    end   
   
    userdataJSON = JSON.generate('type'=>'regRequest', 'login' =>login, 'email' =>email, 'pass'=>pass, 'fName'=>fName, 'sName'=>sName, 'position'=>pos)
    @socket.puts Security.encrypt(userdataJSON)
    Thread.new do
      while(true)
        @serverMsg=@socket.recv(10000)
        self.data_sort(Security.decrypt(@serverMsg))
      end
    end
  end

  #Method for sorting received messages
  def self.data_sort(servMsg)
    result = false
    
    if JSON.parse(servMsg)["type"] == "confirmation"
      if JSON.parse(servMsg)["isCorrectCredentials"] == "true"
        @username=JSON.parse(servMsg)["name"]
        ClientController.accessGranted @username
      elsif JSON.parse(servMsg)["isCorrectCredentials"] == "alreadyConnected"
        @socket.close
        ClientController.alreadyConnected JSON.parse(servMsg)["name"]
      else
        @socket.close
        ClientController.accessDenied
      end
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "regResponse"
      @socket.close
      if JSON.parse(servMsg)["conflictedData"] == "" && JSON.parse(servMsg)["exception"] == ""
        ClientController.regSuccess
      else
        ClientController.regFailed(JSON.parse(servMsg)["conflictedData"], JSON.parse(servMsg)["exception"])
      end
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "connections"
      ClientController.refreshUserList(JSON.parse(servMsg)["users"])
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "message"
      ClientController.receiveMsg JSON.parse(servMsg)["msg"], JSON.parse(servMsg)["user"] 
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "messages"
      ClientController.showMsgHistory JSON.parse(servMsg)["user"], JSON.parse(servMsg)["messages"]
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "newClient"
      ClientController.userConnected(JSON.parse(servMsg)["name"])
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "lostClient" 
      ClientController.userDisconnected(JSON.parse(servMsg)["name"])
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "busy"
      ClientController.setUserBusy(JSON.parse(servMsg)["name"])
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "currentUserData"
      @username = JSON.parse(servMsg)["login"]
      @email = JSON.parse(servMsg)["email"]
      @fName = JSON.parse(servMsg)["fName"]
      @sName = JSON.parse(servMsg)["sName"]
      @position = JSON.parse(servMsg)["position"]
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "dataChanged"
      @username = JSON.parse(servMsg)["login"]
      @email = JSON.parse(servMsg)["email"]
      @fName = JSON.parse(servMsg)["fName"]
      @sName = JSON.parse(servMsg)["sName"]
      @position = JSON.parse(servMsg)["position"]
      ClientController.dataChanged
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "userData"
      ClientController.showUserData(JSON.parse(servMsg)["user"], JSON.parse(servMsg)["email"], JSON.parse(servMsg)["fName"], JSON.parse(servMsg)["sName"], JSON.parse(servMsg)["position"], false)
      result = true
    end
    
    return result
  end
  
  #Request for change user data on the server 
  def self.changeUserData(email, pass, fName, sName, pos)
    userdataJSON = JSON.generate('type'=>'changeUserData', 'login' =>@username, 'email' =>email, 'pass'=>pass, 'fName'=>fName, 'sName'=>sName, 'position'=>pos)  
    begin 
      @socket.puts Security.encrypt(userdataJSON)
    rescue SystemCallError, IOError
      ClientController.connectionLost
    end
  end
  
  #Change user status on the server
  def self.changeStatus(status)
    statusJSON = JSON.generate('type'=>'status', 'status'=>status)
    begin
      @socket.puts Security.encrypt(statusJSON)
    rescue SystemCallError, IOError
      ClientController.connectionLost
    end
  end
  
  def self.requestMsgHistory(user)
    requestHistory = JSON.generate('type'=>'getMessages', 'user'=>user)
    begin
      @socket.puts Security.encrypt(requestHistory)
    rescue SystemCallError, IOError
        ClientController.connectionLost
    end
  end
  
  def self.requestUserData(user)
    requestUData = JSON.generate('type'=>'getUserData', 'user'=>user)
    begin
      @socket.puts Security.encrypt(requestUData)
    rescue SystemCallError, IOError
      ClientController.connectionLost
    end
  end

  #Sending message
  def self.send(msg, receiver)
    Thread.new do
      msgJSON = JSON.generate('type'=>'message', 'user' =>@username, 'msg'=>msg, 'to'=>receiver)
      begin
        @socket.puts Security.encrypt(msgJSON)
      rescue SystemCallError, IOError
        ClientController.connectionLost
      end
    end
  end
  
  #START GETTERS REGION
  def self.get_username
    return @username
  end
  
  def self.get_email
    return @email
  end
  
  def self.get_fName
    return @fName
  end
  
  def self.get_sName
    return @sName
  end
  
  def self.get_position
    return @position
  end
  #END GETTERS REGION
end