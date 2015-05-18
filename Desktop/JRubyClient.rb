require 'socket'
require 'json'
require 'date'

include Java

import java.awt.GridLayout
import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.Font
import java.awt.Image

import java.awt.PopupMenu
import java.awt.SystemTray
import java.awt.Toolkit
import java.awt.TrayIcon
import java.awt.MenuItem
import java.awt.event.ActionEvent
import java.awt.event.ActionListener
import java.awt.event.MouseAdapter

import javax.swing.SwingUtilities
import javax.swing.JFrame
import javax.swing.Box
import javax.swing.JPanel
import javax.swing.JLabel
import javax.swing.JTextField
import javax.swing.JTextArea
import javax.swing.JPasswordField
import javax.swing.JButton
import javax.swing.JComboBox
import javax.swing.DefaultListModel
import javax.swing.JList
import javax.swing.JScrollPane
import javax.swing.JOptionPane
import javax.swing.ListCellRenderer
import javax.swing.ImageIcon

class MsgWindow
  include ActionListener
  attr_accessor :frame, :messages, :outMsg, :title
  
  def initialize(title)
    @title=title
  end
  
  def open
    frame = JFrame.new
   
    basic = JPanel.new
    basic.setLayout BorderLayout.new
    bottom = JPanel.new
    bottom.setLayout GridLayout.new 1,2
    bottom.setMaximumSize(Dimension.new(350, 20))
     
    font = Font.new "Verdana", Font::PLAIN, 16

    @messages = JTextArea.new   
    @messages.setEditable false
    @outMsg = JTextField.new
    sendB = JButton.new "Send"
    sendB.setFont font
    
    sendB.addActionListener{ |e| 
      msg = @outMsg.getText
      @outMsg.setText ""
      ClientController.sendMsg msg, @title, self
    }
    
    basic.add @messages, BorderLayout::CENTER
    bottom.add @outMsg
    bottom.add sendB
    basic.add bottom, BorderLayout::SOUTH
    frame.add basic
    frame.pack
    
    frame.setSize 350, 350
    frame.setLocationRelativeTo nil
    frame.setTitle @title
    frame.setVisible true
    
    frame.add_window_listener(java.awt.event.WindowListener.impl {|m,*a| $msgWindows.delete self if m == :windowClosing })
  end
end


class ClientGUI
  include ActionListener
  
  attr_accessor :login, :password, :server, :loginR, :emailR, :passwordR, :fNameR, :sNameR, :posR, :serverR,
                :outMsg, :listModel, :logInWin, :regWin, :mainWin, :trayIcon, :list

public
  
  def initialize
    openLogInWindow
  end
      
  def openLogInWindow
    @logInWin = JFrame.new
    basic = JPanel.new
    basic.setLayout GridLayout.new 8,1
    bottom = JPanel.new
    bottom.setLayout GridLayout.new 1,3
    
    font = Font.new "Verdana", Font::PLAIN, 16
    
    loginL = JLabel.new "Login"
    loginL.setFont font
    
    passwordL = JLabel.new "Password"
    passwordL.setFont font
    
    serverL = JLabel.new "Server"
    serverL.setFont font
    
    @login = JTextField.new
    @login.setFont font
    
    @password = JPasswordField.new
    @password.setFont font
    
    @server = JTextField.new "localhost:5196"
    @server.setFont font
    
    loginB = JButton.new "Sign in"
    loginB.setFont font
    loginB.addActionListener{|e| ClientController.signIn @login.getText, @password.getText, @server.getText}
    
    register = JButton.new "Registration"
    register.setFont font
    register.addActionListener{|e| 
      @logInWin.setVisible false
      openRegistrationWindow
    }
    
    basic.add loginL
    basic.add @login
    basic.add passwordL
    basic.add @password
    basic.add serverL
    basic.add @server
    basic.add Box.createRigidArea Dimension.new
    bottom.add loginB
    bottom.add Box.createRigidArea Dimension.new
    bottom.add register
    basic.add bottom
    @logInWin.add basic
    @logInWin.pack
    
    @logInWin.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
    @logInWin.setSize 350, 350
    @logInWin.setLocationRelativeTo nil
    @logInWin.setTitle "Log In"
    @logInWin.setVisible true
  end
  
  def openRegistrationWindow
    @regWin = JFrame.new
    basic = JPanel.new
    basic.setLayout GridLayout.new 16,1
    bottom = JPanel.new
    bottom.setLayout GridLayout.new 1,3
    
    font = Font.new "Verdana", Font::PLAIN, 16
    
    loginL = JLabel.new "Login"
    loginL.setFont font
    
    emailL = JLabel.new "Email"
    emailL.setFont font
    
    passwordL = JLabel.new "Password"
    passwordL.setFont font
    
    fNameL = JLabel.new "First Name"
    fNameL.setFont font
    
    sNameL = JLabel.new "Second Name"
    sNameL.setFont font
    
    posL = JLabel.new "Position"
    posL.setFont font
    
    serverL = JLabel.new "Server"
    serverL.setFont font
    
    @loginR = JTextField.new
    @loginR.setFont font
    
    @emailR = JTextField.new
    @emailR.setFont font
    
    @passwordR = JPasswordField.new
    @passwordR.setFont font
    
    @fNameR = JTextField.new
    @fNameR.setFont font
    
    @sNameR = JTextField.new
    @sNameR.setFont font
    
    @posR = JTextField.new
    @posR.setFont font

    @serverR = JTextField.new
    @serverR.setFont font
    
    submitB = JButton.new "Submit"
    submitB.setFont font
    submitB.addActionListener{|e| ClientController.registration @loginR.getText, @emailR.getText, @passwordR.getText, @fNameR.getText, @sNameR.getText, @posR.getText, @serverR.getText}
    
    backB = JButton.new "Back"
    backB.setFont font
    backB.addActionListener{|e|
      @regWin.setVisible false
      @logInWin.setVisible true
    }
    
    basic.add loginL
    basic.add @loginR
    basic.add emailL
    basic.add @emailR
    basic.add passwordL
    basic.add @passwordR
    basic.add fNameL
    basic.add @fNameR
    basic.add sNameL
    basic.add @sNameR
    basic.add posL
    basic.add @posR
    basic.add serverL
    basic.add @serverR
    basic.add Box.createRigidArea Dimension.new
    bottom.add submitB
    bottom.add Box.createRigidArea Dimension.new
    bottom.add backB
    basic.add bottom
    @regWin.add basic
    @regWin.pack
    
    @regWin.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
    @regWin.setSize 490, 620
    @regWin.setLocationRelativeTo nil
    @regWin.setTitle "Registration"
    @regWin.setVisible true
  end
  
  def openUserDataWindow(username, email, fName, sName, position)
    @dataWin = JFrame.new
    basic = JPanel.new
    basic.setLayout GridLayout.new 12,1
    
    font = Font.new "Verdana", Font::PLAIN, 16
   
    emailL = JLabel.new "Email"
    emailL.setFont font
    
    passwordL = JLabel.new "New Password"
    passwordL.setFont font
    
    fNameL = JLabel.new "First Name"
    fNameL.setFont font
    
    sNameL = JLabel.new "Second Name"
    sNameL.setFont font
    
    posL = JLabel.new "Position"
    posL.setFont font  
    
    @emailD = JTextField.new email
    @emailD.setFont font
    
    @newPasswordD = JPasswordField.new
    @newPasswordD.setFont font
    
    @fNameD = JTextField.new fName
    @fNameD.setFont font
    
    @sNameD = JTextField.new sName
    @sNameD.setFont font
    
    @posD = JTextField.new position
    @posD.setFont font
    
    changeB = JButton.new "Change"
    changeB.setFont font
    changeB.addActionListener{|e| ClientController.changeUserData @emailD.getText, @newPasswordD.getText, @fNameD.getText, @sNameD.getText, @posD.getText}
    
    basic.add emailL
    basic.add @emailD
    basic.add passwordL
    basic.add @newPasswordD
    basic.add fNameL
    basic.add @fNameD
    basic.add sNameL
    basic.add @sNameD
    basic.add posL
    basic.add @posD
    basic.add Box.createRigidArea Dimension.new
    basic.add changeB
    @dataWin.add basic
    @dataWin.pack
    
    @dataWin.setDefaultCloseOperation JFrame::DISPOSE_ON_CLOSE
    @dataWin.setSize 490, 620
    @dataWin.setLocationRelativeTo nil
    @dataWin.setTitle "User data ["+username+"]"
    @dataWin.setVisible true
  end
  
  def openMainWindow(title)
    self.addTrayIcon title, "images/tray.png"
    @logInWin.setVisible false
    
    @mainWin = JFrame.new
    panel = JPanel.new
    panel.setLayout BorderLayout.new
    
    @listModel= DefaultListModel.new
    @list = JList.new @listModel
    
    statuses = ["Online", "Busy", "Offline"]
    
    @status = JComboBox.new
    statuses.each do |status|
      @status.add_item status
    end
    @status.add_action_listener do |e|
      ClientController.changeStatus @status.get_selected_item
    end
    
    @list.addMouseListener MouseAction.new
    pane = JScrollPane.new
    pane.getViewport.add @list
    panel.add pane, BorderLayout::CENTER
    panel.add @status, BorderLayout::SOUTH
    @mainWin.add panel
    @mainWin.pack
    
    @mainWin.setDefaultCloseOperation JFrame::DISPOSE_ON_CLOSE
    @mainWin.setSize 220, 460
    @mainWin.setLocationRelativeTo nil
    @mainWin.setTitle "Chat ["+title+"]"
    @mainWin.setVisible true
    
    @mainWin.addWindowStateListener do |e|
      if e.getNewState == JFrame::ICONIFIED
        @mainWin.setVisible false
      end
    end
  end
  
  def addTrayIcon(title, pathToImage)
    image = Toolkit.getDefaultToolkit.getImage pathToImage
    
    @trayIcon = TrayIcon.new image, "Chat ["+title+"]"
    if SystemTray.isSupported
      tray = SystemTray.getSystemTray

      @trayIcon.setImageAutoSize true
      @trayIcon.addMouseListener MouseAction.new
      
      popup = PopupMenu.new
      userData =  MenuItem.new "User data"
      aboutItem = MenuItem.new "About"
      exitItem = MenuItem.new "Exit"
      
      userData.addActionListener{|e| openUserDataWindow ClientModel.get_username, ClientModel.get_email, ClientModel.get_fName, ClientModel.get_sName, ClientModel.get_position}
      aboutItem.addActionListener{|e| ClientController.about}
      exitItem.addActionListener{|e| java.lang.System.exit(0)}
      
      popup.add userData
      popup.add aboutItem
      popup.addSeparator
      popup.add exitItem
      
      @trayIcon.setPopupMenu popup
      
      tray.add @trayIcon
    else 
      p "System tray is not supported"
    end
  end
end

class MouseAction < MouseAdapter
  
  def mouseClicked e
    component = e.source
      
    if component.class == Java::JavaxSwing::JList && SwingUtilities::isLeftMouseButton(e) && e.getClickCount == 2 && component.getSelectedIndex != -1
      $msgWindows.each do |win|
        if win.title == component.getSelectedValue
          return
        end
      end
      w = MsgWindow.new component.getSelectedValue
      $msgWindows.push w
      w.open
       
    elsif component.class == Java::JavaAwt::TrayIcon
      if SwingUtilities::isLeftMouseButton(e) && !$app.mainWin.isShowing
          $app.mainWin.setVisible true
          $app.mainWin.setState JFrame::NORMAL
      end
    end   
  end  
end  

class ImageListCellRenderer < Java::javax::swing::JLabel
  include Java::javax.swing.ListCellRenderer
  
  def initialize(status)
    @imgPath = "images/"
    if status == "Online"
      @imgPath = @imgPath+"online.gif"
    elsif status == "Busy"
      @imgPath = @imgPath+"busy.gif"
    end
  end

  def getListCellRendererComponent(list, value, index, isSelected, cellHasFocus)
    label = JLabel.new
    label.setIcon(ImageIcon.new(@imgPath))
    label.setText(value)
    label.setHorizontalTextPosition(JLabel::RIGHT)
    if isSelected
      label.setBackground list.getSelectionBackground
      label.setForeground list.getSelectionForeground
    else
      label.setBackground list.getBackground
      label.setForeground list.getForeground
    end
    label.setEnabled list.isEnabled
    label.setFont list.getFont
    label.setOpaque true
    return label
   end
end

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
  
  def self.about
    JOptionPane.showMessageDialog nil, "Client-server chat\nCreated by Nikita Mogyl'ov", "About", JOptionPane::INFORMATION_MESSAGE
  end
  
  def self.accessGranted(username)
    $app.openMainWindow(username)
  end
  
  def self.registration(login, email, pass, fName, sName, pos, server)
    if login <= " "
      JOptionPane.showMessageDialog nil, "Login should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif email <= " " || !email.match(/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)
      JOptionPane.showMessageDialog nil, "Wrong email", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif pass <= " "
      JOptionPane.showMessageDialog nil, "Password should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif fName <= " " || /\d+/.match(fName)
      JOptionPane.showMessageDialog nil, "First name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif sName <= " " || /\d+/.match(sName)
      JOptionPane.showMessageDialog nil, "Second name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
    elsif pos <= " "
      JOptionPane.showMessageDialog nil, "Position should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif server <= " "
      JOptionPane.showMessageDialog nil, "Server should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    else
      ClientModel.registration login, email, pass, fName, sName, pos, server
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
    if email <= " " || !email.match(/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)
      JOptionPane.showMessageDialog nil, "Wrong email", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif fName <= " " || /\d+/.match(fName)
      JOptionPane.showMessageDialog nil, "First name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif sName <= " " || /\d+/.match(sName)
      JOptionPane.showMessageDialog nil, "Second name should not contain numbers and be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
      
    elsif pos <= " "
      JOptionPane.showMessageDialog nil, "Position should not be empty", "Wrong credentials", JOptionPane::ERROR_MESSAGE
    else
      ClientModel.changeUserData email, pass, fName, sName, pos
    end
  end
  
  def self.changeStatus(status)
    ClientModel.changeStatus(status)
  end
  
  def self.setUserBusy(user)
    $app.list.setCellRenderer(ImageListCellRenderer.new "Busy")
    $app.listModel.removeElement user
    $app.listModel.addElement user
    SwingUtilities.updateComponentTreeUI($app.mainWin)
  end
  
  def self.refreshUserList(users)
    $app.listModel.removeAllElements
    online = JSON.parse(users)["online"]
    busy = JSON.parse(users)["busy"]
    
    online.each do |user|
      if user != ClientModel.get_username
        $app.list.setCellRenderer(ImageListCellRenderer.new "Online")
        $app.listModel.addElement user
      end
    end
    
    busy.each do |user|
      if user != ClientModel.get_username
        $app.list.setCellRenderer(ImageListCellRenderer.new "Busy")
        $app.listModel.addElement user
      end
    end
    SwingUtilities.updateComponentTreeUI($app.mainWin)
  end
  
  def self.userConnected(user)
    $app.list.setCellRenderer(ImageListCellRenderer.new "Online")
    $app.listModel.removeElement user
    $app.listModel.addElement user
    SwingUtilities.updateComponentTreeUI($app.mainWin)
    $app.trayIcon.displayMessage "New connection", "User "+user+" connected", TrayIcon::MessageType::INFO
  end
  
  def self.userDisconnected(user)
    $app.listModel.removeElement user
    SwingUtilities.updateComponentTreeUI($app.mainWin)
  end
end

class ClientModel
  attr_accessor :socket, :serverMsg, :connections, :username, :email, :fName, :sName, :position 

  def self.connect(login, pass, server)
    begin  
      @socket = TCPSocket.new(server.split(':')[0], server.split(':')[1])
    rescue TypeError
      ClientController.wrongServer
    rescue Errno::ECONNREFUSED  
      ClientController.serverNotResponse
      return
    end   
   
    userdataJSON = JSON.generate('type'=>'userdata', 'login' =>login, 'pass'=>pass)   
    @socket.puts userdataJSON   
    Thread.new do
      while(true)
        @serverMsg=@socket.recv(5000)
        self.data_sort(@serverMsg)
      end
    end
  end
  
  def self.registration(login, email, pass, fName, sName, pos, server)
    begin  
      @socket = TCPSocket.new(server.split(':')[0], server.split(':')[1])
    rescue TypeError
      ClientController.wrongServer
    rescue Errno::ECONNREFUSED  
      ClientController.serverNotResponse  
    end   
   
    userdataJSON = JSON.generate('type'=>'regRequest', 'login' =>login, 'email' =>email, 'pass'=>pass, 'fName'=>fName, 'sName'=>sName, 'position'=>pos)   
    @socket.puts userdataJSON
    Thread.new do
      while(true)
        @serverMsg=@socket.recv(5000)
        self.data_sort(@serverMsg)
      end
    end
  end

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
      ClientController.refreshUserList(servMsg)
      result = true
      
    elsif JSON.parse(servMsg)["type"] == "message"
      ClientController.receiveMsg JSON.parse(servMsg)["msg"], JSON.parse(servMsg)["user"] 
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
      
    elsif JSON.parse(servMsg)["type"] == "userData"
      @username = JSON.parse(servMsg)["login"]
      @email = JSON.parse(servMsg)["email"]
      @fName = JSON.parse(servMsg)["fName"]
      @sName = JSON.parse(servMsg)["sName"]
      @position = JSON.parse(servMsg)["position"]
    end
    
    return result
  end
  
  def self.changeUserData(email, pass, fName, sName, pos)
    userdataJSON = JSON.generate('type'=>'changeUserData', 'login' =>@username, 'email' =>email, 'pass'=>pass, 'fName'=>fName, 'sName'=>sName, 'position'=>pos)   
    @socket.puts userdataJSON
  end
  
  def self.changeStatus(status)
    statusJSON = JSON.generate('type'=>'status', 'status'=>status)
    @socket.puts statusJSON
  end

  def self.send(msg, receiver)
    Thread.new do
      msgJSON = JSON.generate('type'=>'message', 'user' =>@username, 'msg'=>msg, 'to'=>receiver)
      @socket.puts msgJSON
    end
  end
  
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
end

$msgWindows = Array.new
$app = ClientGUI.new