$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "data_list_converter"
  s.version     = "0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["linjunhalida"]
  s.email       = ["linjunhalida@gmail.com"]
  s.homepage    = "http://github.com/halida/data_list_converter"
  s.summary     = ""
  s.description = ""

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'spreadsheet'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
