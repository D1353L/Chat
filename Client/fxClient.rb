require 'fox16'  
include Fox  

class LogIn < FXMainWindow  
  def initialize(app)
    super(app, "Log In", :width => 300, :height => 300)
    #font = FXFont.new()
    login_label = FXLabel.new(self, "Login")
    #vFrame = FXVerticalFrame.new(self) 
  end  
 
  def create  
    super  
    show(PLACEMENT_SCREEN)  
  end  
 end
   
 app = FXApp.new
 LogIn.new(app)
 app.create  
 app.run  