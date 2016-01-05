$:.push File.expand_path("lib", __FILE__)

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test

task :console do
  require 'pry'
  require 'data_list_converter'
  Pry.start
end

task :test do
  Dir['test/*_test.rb'].each do |file|
    load file
  end
end

task :build do
  sh 'rm -f *.gem'
  sh 'gem build data_list_converter.gemspec'
end

task :upload do
  sh 'gem push *.gem'
end
