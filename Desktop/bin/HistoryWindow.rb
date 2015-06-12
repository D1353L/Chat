include Java

import javax.swing.JFrame
import java.awt.Font
import java.awt.BorderLayout
import javax.swing.JScrollPane
import javax.swing.JTextArea
import java.awt.event.ActionListener

class HistoryWindow
  attr_accessor :frame, :messages, :title
  
  def initialize(title)
    @title="History ["+title+"]"
  end
  
  def open
    frame = JFrame.new
   
    panel = JPanel.new
    panel.setLayout BorderLayout.new
     
    font = Font.new "Verdana", Font::PLAIN, 16

    @messages = JTextArea.new   
    @messages.setEditable false
    
    pane = JScrollPane.new
    pane.getViewport.add @messages
    panel.add pane, BorderLayout::CENTER
    frame.add panel
    frame.pack
    
    frame.setSize 350, 350
    frame.setLocationRelativeTo nil
    frame.setTitle @title
    frame.setVisible true
    
    frame.add_window_listener(java.awt.event.WindowListener.impl {|m,*a| $historyWindows.delete self if m == :windowClosing })
  end
end
