require 'fox16' 
require 'socket'
require 'json' 
include Fox  

class LogIn < FXMainWindow  
  def initialize(app)
    super(app, "Log In", :width => 300, :height => 300, :opts => DECOR_TITLE|DECOR_CLOSE|DECOR_BORDER|DECOR_MINIMIZE)
    font = FXFont.new(app, "Arial,160")
    @login_label = FXLabel.new(self, "Login")
    @login_label.font = font
    @login_text = FXTextField.new(self, 20, nil, 0, TEXTFIELD_NORMAL|LAYOUT_FILL_X)
    
    @pass_label = FXLabel.new(self, "Password")
    @pass_label.font = font
    @pass_text = FXTextField.new(self, 20, nil, 0, TEXTFIELD_PASSWD|FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X)
    
    @server_label = FXLabel.new(self, "Server")
    @server_label.font = font
    @server_text = FXTextField.new(self, 20, nil, 0, TEXTFIELD_NORMAL|LAYOUT_FILL_X)
    
    @hframe = FXHorizontalFrame.new(self, LAYOUT_FILL_X)
    
    @sign_in = FXButton.new(@hframe, "Sign in")
    @sign_in.font=font
    @sign_in.connect(SEL_COMMAND, method(:sign_in))
    
    @register = FXButton.new(@hframe, "Register", :opts => BUTTON_NORMAL|LAYOUT_RIGHT)
    @register.font=font
    @register.connect(SEL_COMMAND, method(:register))
  end
  
  def sign_in(sender, sel, ptr)
    response = Client.new.sign_in(@login_text.to_s, @pass_text.to_s, @server_text.to_s)
    if response == true
      MainWindow.new(app).create
      self.close
    elsif response == Errno::ECONNREFUSED
      dlg = FXMessageBox.error(self, MBOX_OK, "Error", "Server not responding")
    else
      dlg = FXMessageBox.error(self, MBOX_OK, "Error", "Log in filed, provided credentials are incorrect")
    end
  end
  
  def register(sender, sel, ptr)
    
  end
 
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

class MainWindow < FXMainWindow
  def initialize(app)
    super(app, "Log In", :width => 700, :height => 350, :opts => DECOR_TITLE|DECOR_CLOSE|DECOR_BORDER|DECOR_MINIMIZE)
    font = FXFont.new(app, "Arial,160")
    
    @hframe = FXHorizontalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, 0, 0, 0, 250)
    
    @in_frame = FXVerticalFrame.new(@hframe, LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH,0,0,350)
    @in_label = FXLabel.new(@in_frame, "IN")
    @in_label.font = font
    @in_text = FXText.new(@in_frame, :opts=>TEXT_READONLY|LAYOUT_FILL)
    
    @con_frame = FXVerticalFrame.new(@hframe, LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH,0,0,350)
    @connections_label = FXLabel.new(@con_frame, "CONNECTIONS")
    @connections_label.font = font
    @connections_text = FXText.new(@con_frame, :opts=>TEXT_READONLY|LAYOUT_FILL)
    
    @out_label = FXLabel.new(self, "OUT")
    @out_label.font = font
    
    @out_frame = FXHorizontalFrame.new(self, :opts=>LAYOUT_FILL)
    @out_text = FXText.new(@out_frame, :opts=>LAYOUT_FILL_X)
    @send = FXButton.new(@out_frame, "Send", :opts=>LAYOUT_FILL_Y)
    @send.font=font
    @send.connect(SEL_COMMAND, method(:send))
    
  end
  
  def send(sender, sel, ptr)
    Client.send(@out_text.to_s)
  end
  
  def show_received(msg)
    @in_text.append_text(msg)
  end
  
  def set_connections(connections)
    @connections_text.append_text(connections)
  end
  
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

class Client
 
  $serverPort="5196"
  $username=""

  def sign_in(login, pass, server)
    #$serverPort=server
    begin
      $client = TCPSocket.new('localhost', $serverPort)
    rescue Errno::ECONNREFUSED
      return Errno::ECONNREFUSED
    end
    
    userdataJSON = JSON.generate('type'=>'userdata', 'login' =>login, 'pass'=>pass)
    $client.puts userdataJSON
                
    $serverMsg = $client.sysread(5000)
        
    $serverMsg = JSON.parse($serverMsg)
        
    if($serverMsg["type"] == "confirmation" && $serverMsg["isCorrectCredentials"] == "true") then
      $username=login
      receive
      return true
    else
      $client.close
      return false
    end
  end
 
  def refresh_connections(users)
    Thread.new do
      str=""
      users.each do |user|
        if user!= $username
          str=str+user+"\n"
        end
      end
    end
    MainWindow.set_connections(str)
  end

  def data_sort(servMsg)
    if JSON.parse(servMsg)["type"] == "connections"
      p JSON.parse(servMsg)["users"]
      refresh_connections(JSON.parse(servMsg)["users"])
    
    elsif JSON.parse(servMsg)["type"] == "message"
      now = DateTime.now
      str = "["+now.strftime("%-d.%-m.%Y %H:%M:%S")+"] "+JSON.parse(servMsg)["user"]+": "+JSON.parse(servMsg)["msg"]+"\n"
      p str
      MainWindow.new.show_received(str)
    
    elsif JSON.parse(servMsg)["type"] == "newConnection"
      p "User "+JSON.parse(servMsg)["login"]+" connected\n"
      MainWindow.set_in_msg("User "+JSON.parse(servMsg)["login"]+" connected\n")
    end
  end

  def receive
    Thread.new do
      while(true)
        $serverMsg=$client.sysread(5000)
        data_sort($serverMsg)
      end
    end  
  end

  def send(msg)
    Thread.new do
      msgJSON = JSON.generate('type'=>'message', 'user' =>$username, 'msg'=>msg)
      $client.puts msgJSON
    end
  end
 
  def register
    true
  end
end

   
   
if __FILE__ == $0
  FXApp.new do |app|
    LogIn.new(app)
    app.create
    app.run
  end
end