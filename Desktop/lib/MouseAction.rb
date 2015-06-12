include Java

import java.awt.event.MouseAdapter
import javax.swing.SwingUtilities
import javax.swing.JFrame
import javax.swing.JList

#Class for handling mouse events
class MouseAction < MouseAdapter
  
  def mouseClicked e
    component = e.source
    
    #Dblclick on user from list
    if component.class == Java::JavaxSwing::JList
      if SwingUtilities::isLeftMouseButton(e) && e.getClickCount == 2 && !component.isSelectionEmpty()
        #Checking if window already exist
        $msgWindows.each do |win|
          if win.title == component.getSelectedValue.split(':')[0]
            return
          end
        end
        w = MsgWindow.new component.getSelectedValue.split(':')[0]
        $msgWindows.push w
        w.open
      elsif SwingUtilities::isRightMouseButton(e)
        component.setSelectedIndex(component.locationToIndex e.getPoint)
        $app.listPopup.show(component, e.getX, e.getY)
      end
      
    #Click on tray icon
    elsif component.class == Java::JavaAwt::TrayIcon
      if SwingUtilities::isLeftMouseButton(e) && !$app.mainWin.isShowing
          $app.mainWin.setVisible true
          $app.mainWin.setState JFrame::NORMAL
      end
    end   
  end  
end  