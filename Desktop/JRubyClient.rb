include Java

import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.GraphicsEnvironment

import javax.swing.JFrame
import javax.swing.BorderFactory
import javax.swing.JScrollPane
import javax.swing.JPanel
import javax.swing.JLabel
import javax.swing.JTextField


class Chat < JFrame
  
    def initialize
        super "Quit button"
        
        self.logInWindow
    end
      
    def logInWindow
    @login = JTextField.new
    self.add @login, BorderLayout::NORTH
    self.pack
    
    self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
    self.setLocationRelativeTo nil
    self.setVisible true
    end
  
end

Chat.new