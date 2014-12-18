require 'fox16'  
include Fox  

class LogIn < FXMainWindow  
  def initialize(app)
    super(app, "Log In", :width => 300, :height => 300, :opts => DECOR_TITLE|DECOR_CLOSE|DECOR_BORDER|DECOR_MINIMIZE)
    font = FXFont.new(app, "Arial,160")
    @login_label = FXLabel.new(self, "Login")
    @login_label.font = font
    @login_text = FXTextField.new(self, 20, nil, 0, TEXTFIELD_NORMAL|LAYOUT_FILL_X)
    
    @pass_label = FXLabel.new(self, "Password")
    @pass_label.font = font
    @pass_text = FXTextField.new(self, 20, nil, 0, TEXTFIELD_PASSWD|FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X)
    
    @server_label = FXLabel.new(self, "Server")
    @server_label.font = font
    @server_text = FXTextField.new(self, 20, nil, 0, TEXTFIELD_NORMAL|LAYOUT_FILL_X)
    
    @sign_in = FXButton.new(self, "Sign in", :opts=>LAYOUT_FILL_X)
    @sign_in.font=font
    @sign_in.connect(SEL_COMMAND, method(:sign_in))
    
    @register = FXButton.new(self, "Register", :opts=>LAYOUT_FILL_X)
    @register.font=font
    @register.connect(SEL_COMMAND, method(:register))
  end
  
  def sign_in(sender, sel, ptr)
    MainWindow.new(app).create
    self.close
  end
  
  def register(sender, sel, ptr)
    
  end
 
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

class MainWindow < FXMainWindow
  def initialize(app)
    super(app, "Log In", :width => 700, :height => 350, :opts => DECOR_TITLE|DECOR_CLOSE|DECOR_BORDER|DECOR_MINIMIZE)
    font = FXFont.new(app, "Arial,160")
    
    @hframe = FXHorizontalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, 0, 0, 0, 250)
    
    @in_frame = FXVerticalFrame.new(@hframe, :opts=>LAYOUT_FILL)
    @in_label = FXLabel.new(@in_frame, "IN")
    @in_label.font = font
    @in_text = FXText.new(@in_frame, :opts=>TEXT_READONLY|LAYOUT_FILL)
    
    @con_frame = FXVerticalFrame.new(@hframe, :opts=>LAYOUT_FILL)
    @connections_label = FXLabel.new(@con_frame, "CONNECTIONS")
    @connections_label.font = font
    @connections_text = FXText.new(@con_frame, :opts=>TEXT_READONLY|LAYOUT_FILL)
    
    @out_label = FXLabel.new(self, "OUT")
    @out_label.font = font
    
    @out_frame = FXHorizontalFrame.new(self, :opts=>LAYOUT_FILL)
    @out_text = FXText.new(@out_frame, :opts=>LAYOUT_FILL_X)
    @send = FXButton.new(@out_frame, "Send", :opts=>LAYOUT_FILL_Y)
    @send.font=font
    @send.connect(SEL_COMMAND, method(:send))
    
  end
  
  def send(sender, sel, ptr)
    @in_text.appendText(@out_text.to_s)
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