# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{razor}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mikkel Garcia"]
  s.date = %q{2010-03-03}
  s.description = %q{
    Razor is a simplistic web scraper built on watir-webdriver.
    Razor is not magic it is a tool that straight-up uses the web browser to access web pages and xpath (only xpath) to parse the DOM of a web page.
}
  s.email = %q{lekkim.garcia@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "examples/google.rb",
     "lib/razor.rb",
     "razor.gemspec",
     "test/helper.rb",
     "test/test_razor.rb"
  ]
  s.homepage = %q{http://github.com/mikkel/razor}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simplistic web scraper built on watir-webdriver}
  s.test_files = [
    "test/test_razor.rb",
     "test/helper.rb",
     "examples/google.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_runtime_dependency(%q<watir-webdriver>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<watir-webdriver>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<watir-webdriver>, [">= 0"])
  end
end

