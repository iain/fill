# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fill}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["iain"]
  s.date = %q{2009-09-25}
  s.description = %q{Fill your database}
  s.email = %q{iain@iain.nl}
  s.extra_rdoc_files = ["README.rdoc", "lib/fill.rb", "lib/fill/configure.rb", "lib/fill/presenter.rb", "lib/fill/procedure.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "lib/fill.rb", "lib/fill/configure.rb", "lib/fill/presenter.rb", "lib/fill/procedure.rb", "fill.gemspec"]
  s.homepage = %q{http://iain.nl}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Fill", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{fill}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Fill your database}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
