$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "list_data_converter"
  s.version     = "0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["linjunhalida"]
  s.email       = ["linjunhalida@gmail.com"]
  s.homepage    = "http://github.com/halida/list_data_converter"
  s.summary     = ""
  s.description = ""

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
