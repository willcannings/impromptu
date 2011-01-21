# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{impromptu}
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Will Cannings"]
  s.date = %q{2011-01-21}
  s.description = %q{Component and dependency manager for Ruby}
  s.email = %q{me@willcannings.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "CHANGELOG",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "impromptu.gemspec",
    "lib/impromptu.rb",
    "lib/impromptu/autoload.rb",
    "lib/impromptu/component.rb",
    "lib/impromptu/component_set.rb",
    "lib/impromptu/file.rb",
    "lib/impromptu/folder.rb",
    "lib/impromptu/impromptu.rb",
    "lib/impromptu/ordered_set.rb",
    "lib/impromptu/resource.rb",
    "lib/impromptu/symbol.rb",
    "test/framework/copies/extra_klass2.rb",
    "test/framework/copies/new_klass.rb",
    "test/framework/copies/new_unseen.rb",
    "test/framework/copies/original_klass.rb",
    "test/framework/ext/extensions.rb",
    "test/framework/ext/extensions/blog.rb",
    "test/framework/folder_namespace/stream.rb",
    "test/framework/folder_namespace/two_names.rb",
    "test/framework/lib/group/klass2.rb",
    "test/framework/lib/klass.rb",
    "test/framework/other/also.rb",
    "test/framework/other/ignore.rb",
    "test/framework/other/load.rb",
    "test/framework/other/two.rb",
    "test/framework/preload/preload.rb",
    "test/framework/private/klass.rb",
    "test/framework/private/other.rb",
    "test/framework/stdlib/string.rb",
    "test/framework/stdlib/timeout.rb",
    "test/framework/stdlib/timeout/error.rb",
    "test/framework/test.components",
    "test/helper.rb",
    "test/test_autoload.rb",
    "test/test_component.rb",
    "test/test_component_set.rb",
    "test/test_folder.rb",
    "test/test_impromptu.rb",
    "test/test_integration.rb",
    "test/test_ordered_set.rb",
    "test/test_resource.rb",
    "test/test_stdlib.rb",
    "test/test_symbol.rb"
  ]
  s.homepage = %q{http://github.com/willcannings/impromptu}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Component and dependency manager for Ruby}
  s.test_files = [
    "test/framework/copies/extra_klass2.rb",
    "test/framework/copies/new_klass.rb",
    "test/framework/copies/new_unseen.rb",
    "test/framework/copies/original_klass.rb",
    "test/framework/ext/extensions.rb",
    "test/framework/ext/extensions/blog.rb",
    "test/framework/folder_namespace/stream.rb",
    "test/framework/folder_namespace/two_names.rb",
    "test/framework/lib/group/klass2.rb",
    "test/framework/lib/klass.rb",
    "test/framework/other/also.rb",
    "test/framework/other/ignore.rb",
    "test/framework/other/load.rb",
    "test/framework/other/two.rb",
    "test/framework/preload/preload.rb",
    "test/framework/private/klass.rb",
    "test/framework/private/other.rb",
    "test/framework/stdlib/string.rb",
    "test/framework/stdlib/timeout.rb",
    "test/framework/stdlib/timeout/error.rb",
    "test/helper.rb",
    "test/test_autoload.rb",
    "test/test_component.rb",
    "test/test_component_set.rb",
    "test/test_folder.rb",
    "test/test_impromptu.rb",
    "test/test_integration.rb",
    "test/test_ordered_set.rb",
    "test/test_resource.rb",
    "test/test_stdlib.rb",
    "test/test_symbol.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end

