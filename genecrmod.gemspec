# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: genecrmod 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "genecrmod"
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Edmund Highcock"]
  s.date = "2014-07-23"
  s.description = "A module which allows the GENE gyrokinetic code to be run using the CodeRunner framework. "
  s.email = "edmundhighcock@users.sourceforge.net"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "genecrmod.gemspec",
    "lib/genecrmod.rb",
    "lib/genecrmod/check_parameters.rb",
    "lib/genecrmod/gene.rb",
    "lib/genecrmod/hdf5.rb",
    "lib/genecrmod/namelists.rb",
    "sync_variables/helper.rb",
    "sync_variables/sync_variables.rb",
    "test/linear_run/.CODE_RUNNER_TEMP_RUN_LIST_CACHE"
  ]
  s.homepage = "http://github.com/edmundhighcock/genecrmod"
  s.licenses = ["GPLv3"]
  s.rubygems_version = "2.2.2"
  s.summary = "A module which allows the GENE gyrokinetic code to be run using the CodeRunner framework."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coderunner>, [">= 0.14.2"])
      s.add_runtime_dependency(%q<hdf5>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, ["= 3.0.1"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 4"])
    else
      s.add_dependency(%q<coderunner>, [">= 0.14.2"])
      s.add_dependency(%q<hdf5>, [">= 0"])
      s.add_dependency(%q<shoulda>, ["= 3.0.1"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 4"])
    end
  else
    s.add_dependency(%q<coderunner>, [">= 0.14.2"])
    s.add_dependency(%q<hdf5>, [">= 0"])
    s.add_dependency(%q<shoulda>, ["= 3.0.1"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 4"])
  end
end

