require 'wx'
require 'socket'
require 'json'
include Wx

class LogIn < Frame
    def initialize
        super(nil, -1, "Log In", pos=Point.new(300, 300), Size.new(305,330), :style => Wx::DEFAULT_FRAME_STYLE ^ Wx::RESIZE_BORDER ^ Wx::MAXIMIZE_BOX)
        @panel = Panel.new(self)
        
        font=Font.new()
        font.set_point_size(16)
        font.set_family(FONTFAMILY_MODERN)
        #login
        @login_label = StaticText.new(@panel, -1, "Login")
        @login_label.set_font(font)
        @login_text = TextCtrl.new(@panel, -1, "", DEFAULT_POSITION, Size.new(-1,25))
        
        #password
        @pass_label = StaticText.new(@panel, -1, "Password")
        @pass_label.set_font(font)
        @pass_text = TextCtrl.new(@panel, -1, "", DEFAULT_POSITION, Size.new(-1,25), TE_PASSWORD)
        
        #server address
        @server_label = StaticText.new(@panel, -1, "Server")
        @server_label.set_font(font)
        @server_text = TextCtrl.new(@panel, -1, "", DEFAULT_POSITION, Size.new(-1,25))
        
        #buttons
        @sign_in = Button.new(@panel, 10, "Sign In", DEFAULT_POSITION)
        @register = Button.new(@panel, 20, "Register", DEFAULT_POSITION)
        evt_button(@sign_in.get_id()) { |event| sign_in_click(event)}
        evt_button(@register.get_id()) { |event| register_click(event)}
        
        #adding controls on layout
        @panel_sizer = BoxSizer.new(VERTICAL)
        @panel.set_sizer(@panel_sizer)
        @panel_sizer.add(@login_label, 0, GROW|ALL, 2)
        @panel_sizer.add(@login_text, 0, GROW|ALL, 2)
        @panel_sizer.add(@pass_label, 0, GROW|ALL, 2)
        @panel_sizer.add(@pass_text, 0, GROW|ALL, 2)
        @panel_sizer.add(@server_label, 0, GROW|ALL, 2)
        @panel_sizer.add(@server_text, 0, GROW|ALL, 2)
        @panel_sizer.add(@sign_in, 0, GROW|ALL, 2)
        @panel_sizer.add(@register, 0, GROW|ALL, 2)
    end
    
    def sign_in_click(event)
      resp = Client.new.sign_in(@login_text.get_value(), @pass_text.get_value(), @server_text.get_value())
      if resp == true
        self.close
        MainWindow.new.show
      elsif resp == Errno::ECONNREFUSED
        dlg = MessageDialog.new(@panel, "Server not responding", "Error", OK | ICON_ERROR)
        dlg.show_modal()
      else
        dlg = MessageDialog.new(@panel, "Log in filed, provided credentials are incorrect", "Error", OK | ICON_ERROR)
        dlg.show_modal()
      end
    end
    
    def register_click(event)
      Client.register
    end
end


class MainWindow < Frame
  def initialize
    super(nil, -1, "Client", pos=Point.new(300, 300), Size.new(700,350), :style => DEFAULT_FRAME_STYLE ^ RESIZE_BORDER ^ MAXIMIZE_BOX)
    @panel = Panel.new(self)
        
    font=Font.new()
    font.set_point_size(16)
    font.set_family(FONTFAMILY_MODERN)
        
    #in
    @in_label = StaticText.new(@panel, -1, "IN")
    @in_label.set_font(font)
    @in_text = TextCtrl.new(@panel, -1, "", DEFAULT_POSITION, Size.new(340,200), TE_MULTILINE|TE_READONLY)
        
    #connections
    @connections_label = StaticText.new(@panel, -1, "CONNECTIONS")
    @connections_label.set_font(font)
    @connections_text = TextCtrl.new(@panel, -1, "", DEFAULT_POSITION, Size.new(340,200), TE_MULTILINE|TE_READONLY)
        
    #out
    @out_label = StaticText.new(@panel, -1, "OUT")
    @out_label.set_font(font)
    @out_text = TextCtrl.new(@panel, -1, "", DEFAULT_POSITION, Size.new(600,40))
    @send = Button.new(@panel, 11, "Send", DEFAULT_POSITION)
    evt_button(@send.get_id()) { |event| send_click(event)}
        
    #in vertical sizer
    @in_sizer = BoxSizer.new(VERTICAL)
    @in_sizer.add(@in_label, 0, GROW|ALL, 2)
    @in_sizer.add(@in_text, 0, GROW|ALL, 2)
        
    #connections vertical sizer
    @connections_sizer = BoxSizer.new(VERTICAL)
    @connections_sizer.add(@connections_label, 0, GROW|ALL, 2)
    @connections_sizer.add(@connections_text, 0, GROW|ALL, 2)
        
    #out horizontal sizer
    @out_sizer = BoxSizer.new(HORIZONTAL)
    @out_sizer.add(@out_text, 0, GROW|ALL, 2)
    @out_sizer.add(@send, 0, GROW|ALL, 2)
        
    #horizontal sizer for 'in' and 'connections' vertical sizers
    @h_sizer = BoxSizer.new(HORIZONTAL)
    @h_sizer.add(@in_sizer, 0, GROW|ALL, 2)
    @h_sizer.add(@connections_sizer, 0, GROW|ALL, 2)
        
    #adding sizers to main vertical sizer
    @panel_sizer = BoxSizer.new(VERTICAL)
    @panel.set_sizer(@panel_sizer)
    @panel_sizer.add(@h_sizer, 0, GROW|ALL, 2)
    @panel_sizer.add(@out_label, 0, GROW|ALL, 2)
    @panel_sizer.add(@out_sizer, 0, GROW|ALL, 2)  
  end
 
  def send_click(event)
    Client.new.send(@out_text.get_value)
  end
  
  def show_received(msg)
    @in_text.append_text(msg)
  end
  
  def set_connections(connections)
    @connections_text.append_text(connections)
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
    MainWindow.new.set_connections(str)
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
      MainWindow.new.set_in_msg("User "+JSON.parse(servMsg)["login"]+" connected\n")
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
 
 
Wx::App.run do
 LogIn.new.show
end