include Java

import javax.swing.JFrame
import javax.swing.JPanel
import java.awt.GridLayout
import java.awt.Font
import javax.swing.JLabel
import javax.swing.JTextField
import javax.swing.JPasswordField
import javax.swing.JButton
import java.awt.event.ActionListener


class UserDataWindow
  attr_accessor :title
  
  def initialize(editable=false)
    @editable = editable
  end
  
  def open(username, email, fName, sName, position)
    @title = "User data ["+username+"]"
    frame = JFrame.new
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
    
    @fNameD = JTextField.new fName
    @fNameD.setFont font
    
    @sNameD = JTextField.new sName
    @sNameD.setFont font
    
    @posD = JTextField.new position
    @posD.setFont font
    
    @newPasswordD = JPasswordField.new
    @newPasswordD.setFont font
    
    if !@editable
      @emailD.setEditable false
      @fNameD.setEditable false
      @sNameD.setEditable false
      @posD.setEditable false
    end

    changeB = JButton.new "Change"
    changeB.setFont font
    changeB.addActionListener{|e| ClientController.changeUserData(@emailD.getText, @newPasswordD.getText, @fNameD.getText, @sNameD.getText, @posD.getText)}
    
    basic.add emailL
    basic.add @emailD
    @editable ? (basic.add(passwordL); basic.add(@newPasswordD)) : false
    basic.add fNameL
    basic.add @fNameD
    basic.add sNameL
    basic.add @sNameD
    basic.add posL
    basic.add @posD
    @editable ? (basic.add(Box.createRigidArea(Dimension.new)); basic.add(changeB)) : false
    frame.add basic
    frame.pack
    
    frame.setDefaultCloseOperation JFrame::DISPOSE_ON_CLOSE
    frame.setSize 490, 620
    frame.setLocationRelativeTo nil
    frame.setTitle @title
    frame.setVisible true
    
    frame.add_window_listener(java.awt.event.WindowListener.impl {|m,*a| $userDataWindows.delete self if m == :windowClosing })
  end
end
