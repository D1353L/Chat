require 'tk'  

class LogIn

  def initialize
    root = TkRoot.new do  
      title 'LogIn'
      minsize(300, 300)
      resizable(false,false)
    end
    
    @login_label = TkLabel.new(root) {text "Login"; font TkFont.new('arial 16'); place('relx'=>0,'rely'=>0.0)}
    
    @login_text = Tk::Tile::Entry.new(root) {width 49; place('relx'=>0,'rely'=>0.1)}
    
    @pass_label = TkLabel.new(root) {text "Password"; font TkFont.new('arial 16'); place('relx'=>0,'rely'=>0.2)}
    
    @pass_text = Tk::Tile::Entry.new(root) {width 49; show '*'; place('relx'=>0,'rely'=>0.3)}
    
    @server_label = TkLabel.new(root) {text "Server"; font TkFont.new('arial 16'); place('relx'=>0,'rely'=>0.4)}
    
    @server_text = Tk::Tile::Entry.new(root) {width 49; place('relx'=>0,'rely'=>0.5)}
    
    @sign_in = Tk::Tile::Button.new(root) {text "Sign In"; command 'submitForm'; place('relx'=>0, 'rely'=>0.6)}
    
    @register = Tk::Tile::Button.new(root) {text "Register"; command 'submitForm'; place('relx'=>0.7,'rely'=>0.6)}
    
    Tk.mainloop
  end
end

class MainWindow
  
  def initialize
    root = TkRoot.new do  
      title 'LogIn'
      minsize(700, 300)
      resizable(false,false)
    end
    
    @in_label = TkLabel.new(root) {text "IN"; font TkFont.new('arial 16'); place('relx'=>0,'rely'=>0.0)}
    
    @in_text = TkText.new(root) {width 43; height 10; place('relx'=>0,'rely'=>0.1)}
    
    @connections_label = TkLabel.new(root) {text "CONNECTIONS"; font TkFont.new('arial 16'); place('relx'=>0.5,'rely'=>0.0)}
    
    @connections_text = TkText.new(root) {width 43; height 10; place('relx'=>0.5,'rely'=>0.1)}
    
    Tk.mainloop
  end    
end

MainWindow.new