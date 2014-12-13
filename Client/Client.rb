require 'socket'
require 'json'

class ClientGUI
 
  $server=""
  $username=""
 
  def initialize(app)
    @app = app
  end
 
  def logInWindow
    @app.background gradient rgb(255, 255, 255), rgb(150, 150, 150), :angle => 45
    
    @app.stack do
      @app.flow do
        @app.caption 'Login'
        @login = @app.edit_line :width => '100%', :text=>""
      end
 
      @app.flow do
        @app.caption 'Password'
        @pass = @app.edit_line :width => '100%', :secret => true, :text=>""
      end
 
      @app.flow do
        @app.caption 'Server'
        @serverPortEdit = @app.edit_line :width => '100%'
      end
 
      @app.button "Sign In" do
        $serverPort=@serverPortEdit.text
        $client = TCPSocket.new('localhost', 5196)

        userdataJSON = JSON.generate('type'=>'userdata', 'login' =>@login.text, 'pass'=>@pass.text)
        $client.puts userdataJSON
                
        $serverMsg=$client.sysread(5000)
        
        $serverMsg = JSON.parse($serverMsg)
        
        if($serverMsg["type"] == "confirmation" && $serverMsg["isCorrectCredentials"] == "true") then
          $username=@login.text
          mainWindow
        else
          @app.alert "Log in filed, provided credentials are incorrect"
          $client.close
        end
      end
    end
  end
 
  def mainWindow
  @app.window(:title => $username, :width => 700, :height => 350, :resizable => false) do
    owner.close()

    flow do
      stack :width => '50%' do
        caption 'IN'
        $in = edit_box :width => '100%', :height=> 200, :state=> "disabled"
        $in.text="Connected to "+$serverPort+"\n"
      end
      receive
      stack :width => '50%' do
        caption 'CONNECTIONS'
        $connections = edit_box :width => '100%', :height=> 200, :state=> "disabled"
      end
    end

    stack :margin => 1 do
      caption 'OUT: '
      flow do
        $out = edit_box :width => '90%', :height=>40
        button 'Send', :height=>40 do
          send($out.text)
          $out.text=""
        end
      end
    end
  end
end
end
 

def refresh_connections(users)
  tconnections=Thread.new do
    $connections.text=""
    
    users.each do |user|
      if user!= $username
        $connections.text=$connections.text+user+"\n"
      end
    end
    
  end
end

def data_sort(servMsg)
  if JSON.parse(servMsg)["type"] == "connections"
    refresh_connections(JSON.parse(servMsg)["users"])
    
  elsif JSON.parse(servMsg)["type"] == "message"
    now = DateTime.now
    str = "["+now.strftime("%-d.%-m.%Y %H:%M:%S")+"] "+JSON.parse(servMsg)["user"]+": "+JSON.parse(servMsg)["msg"]+"\n"
    
    $in.text = $in.text+str
    
  elsif JSON.parse(servMsg)["type"] == "newConnection"
    $in.text=$in.text+"User "+JSON.parse(servMsg)["login"]+" connected\n"
  end
end

def receive
  treceive=Thread.new do
    while(true)
      $serverMsg=$client.sysread(5000)
      data_sort($serverMsg)
    end
  end  
end

def send(msg)
  tsend=Thread.new do
    msgJSON = JSON.generate('type'=>'message', 'user' =>$username, 'msg'=>msg)
    $client.puts msgJSON
  end
end
 
Shoes.app(:title => 'Log In', :width => 300, :height => 300, :resizable => false){
  clientobj=ClientGUI.new(self)
  clientobj.logInWindow
}