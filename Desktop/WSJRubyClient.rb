require 'socket'
require 'json'
require 'io/wait'
require 'faye/websocket'
require 'eventmachine'


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
import javax.swing.JOptionPane


class ClientGUI
  include ActionListener
  
  attr_accessor :login, :password, :server, :messages, :outMsg, :listModel, :logInWin, :mainWin, :msgWin

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
    
    @server = JTextField.new
    @server.setFont font
    
    loginB = JButton.new "Sign in"
    loginB.setFont font
    loginB.addActionListener self
    
    register = JButton.new "Register"
    register.setFont font
    register.addActionListener self
    
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
  
  def openMainWindow
    ClientModel.receive
    @logInWin.setVisible false
    
    @mainWin = JFrame.new
    panel = JPanel.new
    panel.setLayout GridLayout.new 1,1
    
    @listModel= DefaultListModel.new
    list = JList.new @listModel
    
    list.add_list_selection_listener do |e|

        sender = e.source

        if not e.getValueIsAdjusting
          self.openMsgWindow sender.getSelectedValue
        end
    end

    pane = JScrollPane.new
    pane.getViewport.add list
    panel.add pane
    @mainWin.add panel
    @mainWin.pack
    
    @mainWin.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
    @mainWin.setSize 220, 460
    @mainWin.setLocationRelativeTo nil
    @mainWin.setTitle "Chat"
    @mainWin.setVisible true
  end
  
  def openMsgWindow(user)
    @msgWin = JFrame.new
    basic = JPanel.new
    basic.setLayout GridLayout.new 2,1
    bottom = JPanel.new
    bottom.setLayout GridLayout.new 1,2
    
    font = Font.new "Verdana", Font::PLAIN, 16

    @messages = JTextArea.new   
    @messages.setEditable false
    @outMsg = JTextField.new   
    sendB = JButton.new "Send"
    sendB.setFont font
    sendB.addActionListener self
    
    basic.add @messages
    bottom.add @outMsg
    bottom.add sendB
    basic.add bottom
    @msgWin.add basic
    @msgWin.pack
    
    @msgWin.setSize 350, 350
    @msgWin.setLocationRelativeTo nil
    @msgWin.setTitle user
    @msgWin.setVisible true
  end
  
  def actionPerformed(ev)
    if ev.getActionCommand == "Sign in"
      send ClientController.signIn @login.getText, @password.getText, @server.getText
    elsif ev.getActionCommand == "Register"
      send ClientController.register
    elsif ev.getActionCommand == "Send"
      send ClientController.sendMsg @outMsg.getText, @msgWin.getTitle
    else
      raise "Wrong command"+ev.getActionCommand
    end
  end
end

class ClientController
  
  def self.signIn(login, pass, server)
    response = ClientModel.sign_in(login, pass, server)
    if response == true
      $app.openMainWindow
    elsif response == Errno::ECONNREFUSED
      JOptionPane.showMessageDialog nil, "Server not responding", "Connection error", JOptionPane::ERROR_MESSAGE   
    else
      JOptionPane.showMessageDialog nil, "Log in filed, provided credentials are incorrect", "Log in error", JOptionPane::ERROR_MESSAGE   
    end   
  end
  
  def register
    
  end
  
  def self.sendMsg(msg, receiver)
    ClientModel.send msg, receiver
  end
  
  def self.receiveMsg
    
  end
  
  def self.refreshUserList(users) 
    $app.listModel.removeAllElements   
    p users.sort
    users.each do |user|
      $app.listModel.addElement user
    end
    SwingUtilities.updateComponentTreeUI($app.mainWin);
  end
end

class ClientModel
  attr_accessor :socket, :serverMsg, :connections, :username

  def self.sign_in(login, pass, server)
    EM.run{
      @socket = Faye::WebSocket::Client.new('ws://localhost:5168/')   
   
      userdataJSON = JSON.generate('type'=>'userdata', 'login' =>login, 'pass'=>pass)   
      @socket.send userdataJSON   
   
      @socket.on :message do |event|
        p event.data
        @serverMsg = JSON.parse(event.data)
        if(@serverMsg["type"] == "confirmation" && @serverMsg["isCorrectCredentials"] == "true") then   
          @username=login
          return true   
        elsif !self.data_sort(event.data)
          @socket.close
          return false  
        end
      end 
    
      @socket.on :close do |event|
        @socket = nil
      end
    }
  end

  def self.data_sort(servMsg)
    if JSON.parse(servMsg)["type"] == "connections"
      p "connections"
      ClientController.refreshUserList(JSON.parse(servMsg)["users"])
      return true
    elsif JSON.parse(servMsg)["type"] == "message"
      now = DateTime.now
      str = "["+now.strftime("%-d.%-m.%Y %H:%M:%S")+"] "+JSON.parse(servMsg)["user"]+": "+JSON.parse(servMsg)["msg"]+"\n"
      ClientController.receiveMsg str
      return true
    end
    return false
  end

  def self.receive
    Thread.new do
      i=1
      while(true)
        if @socket.ready?
          p @serverMsg=@socket.recv(5000)
          self.data_sort(@serverMsg)
        end
        #p i+=1
      end
    end  
  end

  def self.send(msg, receiver)
    Thread.new do
      msgJSON = JSON.generate('type'=>'message', 'user' =>@username, 'msg'=>msg, 'to'=>receiver)
      @socket.puts msgJSON
    end
  end
end

$app = ClientGUI.new