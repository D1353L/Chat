include Java

import java.awt.GridLayout
import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.Font

import java.awt.PopupMenu
import java.awt.SystemTray
import java.awt.Toolkit
import java.awt.TrayIcon
import java.awt.MenuItem
import java.awt.event.ActionEvent
import java.awt.event.ActionListener

import javax.swing.JPopupMenu
import javax.swing.JMenuItem
import javax.swing.JFrame
import javax.swing.Box
import javax.swing.JPanel
import javax.swing.JLabel
import javax.swing.JTextField
import javax.swing.JPasswordField
import javax.swing.JButton
import javax.swing.JComboBox
import javax.swing.DefaultListModel
import javax.swing.JList
import javax.swing.JScrollPane



#Class for Graphical user interface(GUI)
class ClientGUI
  include ActionListener
  
  attr_accessor :login, :password, :server, :loginR, :emailR, :passwordR, :fNameR, :sNameR, :posR, :serverR,
                :outMsg, :listModel, :logInWin, :regWin, :mainWin, :trayIcon, :list, :listPopup

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
    
    @server = JTextField.new "localhost:49005"
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
  
  def openMainWindow(title)
    self.addTrayIcon title, "./lib/images/tray.png"
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
      ClientController.changeStatus @status.get_selected_item.downcase!
    end
    
    @listPopup = JPopupMenu.new
    userData =  JMenuItem.new "User data"
    history =  JMenuItem.new "History"
    @listPopup.add userData
    @listPopup.add history
    
    userData.addActionListener{|e| (!@list.isSelectionEmpty) ? (ClientController.requestUserData(@list.getSelectedValue.split(':')[0])) : (false)}
    history.addActionListener{|e| (!@list.isSelectionEmpty) ? (ClientController.requestMsgHistory(@list.getSelectedValue.split(':')[0])) : (false)}
    
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
      
      trayPopup = PopupMenu.new
      userData = MenuItem.new "User data"
      aboutItem = MenuItem.new "About"
      exitItem = MenuItem.new "Exit"
      
      userData.addActionListener{|e| ClientController.showUserData(ClientModel.get_username, ClientModel.get_email, ClientModel.get_fName, ClientModel.get_sName, ClientModel.get_position, true)}
      aboutItem.addActionListener{|e| ClientController.about}
      exitItem.addActionListener{|e| java.lang.System.exit(0)}
      
      trayPopup.add userData
      trayPopup.add aboutItem
      trayPopup.addSeparator
      trayPopup.add exitItem
      
      @trayIcon.setPopupMenu trayPopup
      
      tray.add @trayIcon
    else 
      p "System tray is not supported"
    end
  end
end