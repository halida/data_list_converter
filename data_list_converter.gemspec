$:.push File.expand_path("../lib", __FILE__)
require "data_list_converter/version"

Gem::Specification.new do |s|
  s.name        = "data_list_converter"
  s.version     = DataListConverter::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["linjunhalida"]
  s.email       = ["linjunhalida@gmail.com"]
  s.homepage    = "http://github.com/halida/data_list_converter"
  s.summary     = "convert data between different formats"
  s.description = "Data List Converter is a tool to convert data between different formats."
  s.licenses    = ["MIT"]

  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'minitest', '~> 5.7'
  s.add_development_dependency 'spreadsheet', '~> 1.0'
  s.add_development_dependency 'rubyXL', '3.3.15'
  s.add_development_dependency 'pry', '~> 0.10.1'
  s.add_development_dependency 'sqlite3', "1.3.11"
  s.add_development_dependency 'activerecord', '~> 4.2'
  s.add_development_dependency 'xlsxtream'
  s.add_development_dependency 'creek'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
