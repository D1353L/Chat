include Java

import javax.swing.ListCellRenderer
import javax.swing.JLabel
import javax.swing.ImageIcon

#Class for adding images to list
class ImageListCellRenderer < Java::javax::swing::JLabel
  include Java::javax.swing.ListCellRenderer

  def getListCellRendererComponent(list, value, index, isSelected, cellHasFocus)
    label = JLabel.new
    label.setIcon(ImageIcon.new("./lib/images/"+value.split(':')[1]+".gif"))
    label.setText(value.split(':')[0])
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