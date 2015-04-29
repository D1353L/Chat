require 'socket'
require 'json'

include Java

import java.awt.GridLayout
import java.awt.Dimension
import java.awt.Font
import java.awt.event.ActionListener

import javax.swing.JFrame
import javax.swing.Box
import javax.swing.JPanel
import javax.swing.JLabel
import javax.swing.JTextField
import javax.swing.JTextArea
import javax.swing.JPasswordField
import javax.swing.JButton
import javax.swing.DefaultListModel
import javax.swing.JList
import javax.swing.JScrollPane


class ClientGUI < JFrame
  include ActionListener
  
  def initialize
    super "Log In"
    self.logInWindow
  end
      
  def logInWindow
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
    
    login = JTextField.new
    login.setFont font
    
    password = JPasswordField.new
    password.setFont font
    
    server = JTextField.new
    server.setFont font
    
    loginB = JButton.new "Log in"
    loginB.setFont font
    loginB.addActionListener self
    
    register = JButton.new "Register"
    register.setFont font
    register.addActionListener self
    
    basic.add loginL
    basic.add login
    basic.add passwordL
    basic.add password
    basic.add serverL
    basic.add server
    basic.add Box.createRigidArea Dimension.new
    bottom.add loginB
    bottom.add Box.createRigidArea Dimension.new
    bottom.add register
    basic.add bottom
    self.add basic
    self.pack
    
    self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
    self.setSize 350, 350
    self.setLocationRelativeTo nil
    self.setVisible true
  end
  
  def mainWindow
    mainWin = JFrame.new
    panel = JPanel.new
    panel.setLayout GridLayout.new 1,1
    
    users = Array.new ["john", "iva", "orest", "admin"].sort
    
    listModel= DefaultListModel.new
    
    users.each do |user|
      listModel.addElement user
    end
    
    list = JList.new listModel
    
    list.add_list_selection_listener do |e|

        sender = e.source

        if not e.getValueIsAdjusting
          msgWindow sender.getSelectedValue
        end
    end

    pane = JScrollPane.new
    pane.getViewport.add list
    panel.add pane
    mainWin.add panel
    mainWin.pack
    
    mainWin.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
    mainWin.setSize 220, 460
    mainWin.setLocationRelativeTo nil
    mainWin.setTitle "Chat"
    mainWin.setVisible true
  end
  
  def msgWindow(user)
    msgWin = JFrame.new
    basic = JPanel.new
    basic.setLayout GridLayout.new 2,1
    bottom = JPanel.new
    bottom.setLayout GridLayout.new 1,2
    
    font = Font.new "Verdana", Font::PLAIN, 16

    messages = JTextArea.new   
    messages.setEditable false 
    out = JTextField.new   
    sendB = JButton.new "Send"
    sendB.setFont font
    sendB.addActionListener self
    
    basic.add messages
    bottom.add out
    bottom.add sendB
    basic.add bottom
    msgWin.add basic
    msgWin.pack
    
    msgWin.setSize 350, 350
    msgWin.setLocationRelativeTo nil
    msgWin.setTitle user
    msgWin.setVisible true
  end
  
  def actionPerformed(ev)
    if ev.getActionCommand == "Log in"
      send self.logIn
    elsif ev.getActionCommand == "Register"
      send self.register
    elsif ev.getActionCommand == "Send"
      send self.sendMsg
    else
      raise "Wrong command"+ev.getActionCommand
    end
  end
  
  def logIn
    self.setVisible false
    mainWindow
  end
  
  def register
    self.setVisible false
    mainWindow
  end
  
  def sendMsg
    self.setVisible false
    mainWindow
  end
  
  def receiveMsg
    
  end
  
  def refreshUserList
    
  end
  
end

class ClientModel

  def sign_in(login, pass, server)
    begin   
      $socket = TCPSocket.new('localhost', server)   
    rescue Errno::ECONNREFUSED  
      return Errno::ECONNREFUSED  
    end   
   
    userdataJSON = JSON.generate('type'=>'userdata', 'login' =>login, 'pass'=>pass)   
    $socket.puts userdataJSON   
   
    $serverMsg = $socket.sysread(5000)  
   
    $serverMsg = JSON.parse($serverMsg)   
   
    if($serverMsg["type"] == "confirmation" && $serverMsg["isCorrectCredentials"] == "true") then   
      $username=login  
      return true   
    else  
      $socket.close   
      return false  
    end
  end

  def refresh_connections(users)
    Thread.new do
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
    Thread.new do
      while(true)
        $serverMsg=$socket.sysread(5000)
        data_sort($serverMsg)
      end
    end  
  end

  def send(msg)
    Thread.new do
      msgJSON = JSON.generate('type'=>'message', 'user' =>$username, 'msg'=>msg)
      $socket.puts msgJSON
    end
  end
end

ClientGUI.new