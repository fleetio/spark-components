# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "spark_components/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spark_components"
  s.version     = SparkComponents::VERSION
  s.authors     = ["Jens Ljungblad", "Brandon Mathis"]
  s.email       = ["jens.ljungblad@gmail.com", "brandon@imathis.com"]
  s.homepage    = "https://www.github.com/imathis/components"
  s.summary     = "Simple view components for Rails 5.1+"
  s.description = "Simple view components for Rails 5.1+"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.1.0"

  s.add_development_dependency "rubocop"
  s.add_development_dependency "sqlite3"
end
