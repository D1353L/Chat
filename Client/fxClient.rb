require 'fox16'  
include Fox  

class LogIn < FXMainWindow  
  def initialize(app)
    super(app, "Log In", :width => 300, :height => 300)
    font = FXFont.new(app, "Arial,160")
    login_label = FXLabel.new(self, "Login")
    login_label.font = font
    login_text = FXTextField.new(self, 1, nil, 0, TEXTFIELD_NORMAL,0,0, :width => 300, :height => 20)
  end
 
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end
   
   
if __FILE__ == $0
  FXApp.new do |app|
    LogIn.new(app)
    app.create
    app.run
  end
end 