require 'tk'  

class LogIn

  def initialize
    root = TkRoot.new do  
      title 'LogIn'  
      # the min size of window  
      minsize(300, 300)
    end
    
    @login_label = TkLabel.new(root) { 
      text "Login"
      font TkFont.new('arial 16')
      pack('side'=>'top')
    }
    
    @login_text = Tk::Tile::Entry.new(root) {
      pack('side'=>'top')
    }
    
    @pass_label = TkLabel.new(root) { 
      text "Password" 
      font TkFont.new('arial 16')
      pack('side'=>'top')
    }
    
    @pass_text = Tk::Tile::Entry.new(root) {
      pack('side'=>'top')
    }
    
    @server_label = TkLabel.new(root) { 
      text "Server" 
      font TkFont.new('arial 16')
      pack('side'=>'top')  
    }
    
    @server_text = Tk::Tile::Entry.new(root) {
      pack('side'=>'top')
    }
    
    @sign_in = Tk::Tile::Button.new(root) {
      text 'Sign In'
      command 'submitForm'
      pack('side'=>'top')
    }
    
    @register = Tk::Tile::Button.new(root) {
      text 'Register'
      command 'submitForm'
      pack('side'=>'top')
    }
    
    Tk.mainloop  
  end
end

LogIn.new