$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "menu_maker/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "menu_maker"
  s.version     = MenuMaker::VERSION
  s.authors     = ["Thiago A. Silva"]
  s.email       = ["thiago@mixinternet.com.br"]
  s.summary     = %q{Flexible solution to build any kind of menu in any Ruby framework}
  s.description = %q{Flexible solution to build any kind of menu in any Ruby framework. Currently the best integration is with Rails. Supports recursive menus.}
  s.homepage    = "http://github.com/thiagoa/menu_maker"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rails", "~> 4.0"
  s.add_development_dependency "shoulda-context", "~> 1.2.1"
end
