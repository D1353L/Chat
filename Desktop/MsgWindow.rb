include Java

import javax.swing.JFrame
import javax.swing.JPanel
import java.awt.GridLayout
import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.Font
import java.awt.event.ActionListener
import javax.swing.JScrollPane
import javax.swing.JTextField
import javax.swing.JTextArea
import javax.swing.JButton

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
    
    pane = JScrollPane.new
    pane.getViewport.add @messages
    basic.add pane, BorderLayout::CENTER
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