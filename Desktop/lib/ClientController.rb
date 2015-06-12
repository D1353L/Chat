include Java
import javax.swing.JOptionPane

#Class for connection with ClientGUI and CLientModel
class ClientController
  
  def self.signIn(login, pass, server)
    ClientModel.connect(login, pass, server)
  end
  
  def self.serverNotResponse
    JOptionPane.showMessageDialog nil, "Server not response", "Log in failed", JOptionPane::ERROR_MESSAGE
  end
  
  def self.wrongServer
    JOptionPane.showMessageDialog nil, "Wrong server address", "Log in failed", JOptionPane::ERROR_MESSAGE
  end
  
  def self.accessDenied
    JOptionPane.showMessageDialog nil, "Log in filed, provided credentials are incorrect", "Log in failed", JOptionPane::ERROR_MESSAGE
  end
  
  def self.alreadyConnected(username)
    JOptionPane.showMessageDialog nil, "User "+username+" is already connected", "Log in failed", JOptionPane::ERROR_MESSAGE
  end
  
  def self.connectionLost
    JOptionPane.showMessageDialog nil, "Connection lost", "Connection lost", JOptionPane::ERROR_MESSAGE
    java.lang.System.exit(0)
  end
  
  def self.about
    JOptionPane.showMessageDialog nil, "Client-server chat\nCreated by Nikita Mogyl'ov", "About", JOptionPane::INFORMATION_MESSAGE
  end
  
  def self.dataChanged
    JOptionPane.showMessageDialog nil, "Data changed successfully", "User data", JOptionPane::INFORMATION_MESSAGE
  end
  
  def self.accessGranted(username)
    $app.openMainWindow(username)
  end
  
  def self.registration(login, email, pass, fName, sName, pos, server)
    if login == "" || login.match(/\s/)
      JOptionPane.showMessageDialog nil, "Login should not contain spaces and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif email == " " || !email.match(/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)
      JOptionPane.showMessageDialog nil, "Wrong email", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif pass == "" || pass.match(/\s/)
      JOptionPane.showMessageDialog nil, "Password should not contain spaces and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif fName == "" || /\d+/.match(fName)
      JOptionPane.showMessageDialog nil, "First name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif sName == "" || /\d+/.match(sName)
      JOptionPane.showMessageDialog nil, "Second name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif pos == ""
      JOptionPane.showMessageDialog nil, "Position should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif server == ""
      JOptionPane.showMessageDialog nil, "Server should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    else
      ClientModel.registration login.strip, email.strip, pass.strip, fName.strip, sName.strip, pos.strip, server.strip
    end
  end
  
  def self.regSuccess
    JOptionPane.showMessageDialog nil, "New user registered successfully", "Registered", JOptionPane::INFORMATION_MESSAGE
    @regWin.setVisible false
    @logInWin.setVisible true
  end
  
  def self.regFailed(conflictedData, exception)
    if conflictedData == ""
      JOptionPane.showMessageDialog nil, "Next exception is occured on the server: "+exception, "Exception", JOptionPane::ERROR_MESSAGE
   
    elsif exception == ""
      JOptionPane.showMessageDialog nil, "Next values are already registered: "+conflictedData, "Wrong credentials", JOptionPane::ERROR_MESSAGE
    end
  end
  
  def self.sendMsg(msg, receiver, msgWin)
    str = "["+DateTime.now.strftime("%-d.%-m.%Y %H:%M:%S")+"] "+ClientModel.get_username+": "+msg+"\n"
    msgWin.messages.append str
    ClientModel.send msg, receiver
  end
  
  def self.receiveMsg(msg, sender)
    str = "["+DateTime.now.strftime("%-d.%-m.%Y %H:%M:%S")+"] "+sender+": "+msg+"\n"
    $msgWindows.each do |win|
      if win.title == sender
        win.messages.append str
        return
      end
    end
    w = MsgWindow.new sender
    $msgWindows.push w
    w.open
    w.messages.append str
  end
  
  def self.changeUserData(email, pass, fName, sName, pos)      
    if email == "" || !email.match(/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)
      JOptionPane.showMessageDialog nil, "Wrong email", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif fName == "" || /\d+/.match(fName)
      JOptionPane.showMessageDialog nil, "First name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif sName == "" || /\d+/.match(sName)
      JOptionPane.showMessageDialog nil, "Second name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif pos == ""
      JOptionPane.showMessageDialog nil, "Position should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
    else
      ClientModel.changeUserData email.strip, pass.strip, fName.strip, sName.strip, pos.strip
    end
  end
  
  def self.requestUserData(username)
    ClientModel.requestUserData(username)
  end
  
  def self.showUserData(user, email, fName, sName, pos, editable)
    $userDataWindows.each do |win|
      if win.title == "User data ["+user+"]"
        return
      end
    end
    w = UserDataWindow.new editable
    $userDataWindows.push w
    w.open(user, email, fName, sName, pos)
  end
  
  def self.requestMsgHistory(user)
    ClientModel.requestMsgHistory(user)
  end

  def self.showMsgHistory(user, msgs)
    msgs.gsub!(/\u0005/, '')
    msgs.gsub!(/\a/, '')
    msgs.gsub!(/\u0004/, '')
    msgs.gsub!(/\u000E/, '')
    msgs.gsub!(/\u0010/, '')
    msgs.gsub!(/\u0001/, '')

    $historyWindows.each do |win|
      if win.title == "History ["+user+"]"
        win.messages.append msgs
        return
      end
    end
    w = HistoryWindow.new user
    $historyWindows.push w
    w.open
    w.messages.append msgs
  end
  
  def self.changeStatus(status)
    ClientModel.changeStatus(status)
  end
  
  def self.setUserBusy(user)
    $app.list.setCellRenderer(ImageListCellRenderer.new)
    $app.listModel.removeElement user
    $app.listModel.addElement user.split(":")[0]+":busy"
    SwingUtilities.updateComponentTreeUI($app.mainWin)
  end
  
  def self.refreshUserList(users)
    $app.listModel.removeAllElements

    users.each do |user|
      if user.split(':')[0] != ClientModel.get_username
        $app.list.setCellRenderer(ImageListCellRenderer.new)
        $app.listModel.addElement user
      end
    end
    SwingUtilities.updateComponentTreeUI($app.mainWin)
  end
  
  def self.userConnected(user)
    $app.list.setCellRenderer(ImageListCellRenderer.new)
    $app.listModel.removeElement user
    $app.listModel.addElement user.split(':')[0]+":online"
    SwingUtilities.updateComponentTreeUI($app.mainWin)
    $app.trayIcon.displayMessage "New connection", "User "+user.split(':')[0]+" connected", TrayIcon::MessageType::INFO
  end
  
  def self.userDisconnected(user)
    $app.listModel.removeElement user
    SwingUtilities.updateComponentTreeUI($app.mainWin)
  end
end