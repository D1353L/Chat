Gem::Specification.new do |s|
  s.name             = 'Chat'
  s.version          = '1.0.0'

  s.authors          = ['Nikita Mogylov']
  s.date             = '2015-06-12'
  s.description      = 'Chat-client'
  s.email            = ['maghanik400@gmail.com']
  s.homepage         = ''
  s.require_paths    = ['lib','bin']
  s.rubygems_version = '1.8.24'
  s.summary          = 'Chat-client'

  s.files            = Dir.glob("{bin,lib}/**/*")
  #s.licenses        = ['MIT']

  s.executables      = ['Main.rb']
end