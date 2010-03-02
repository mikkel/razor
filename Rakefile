require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "razor"
    gem.summary =  %Q{A simplistic web scraper built on watir-webdriver}
    gem.description = %Q{
    Razor is a simplistic web scraper built on watir-webdriver.
    Razor is not magic it is a tool that straight-up uses the web browser to access web pages and xpath (only xpath) to parse the DOM of a web page.
}
    gem.email = "lekkim.garcia@gmail.com"
    gem.homepage = "http://github.com/mikkel/razor"
    gem.authors = ["Mikkel Garcia"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_runtime_dependency "watir-webdriver", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true

end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Razor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

