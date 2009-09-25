require 'rake'
require 'rake/rdoctask'

require 'spec/rake/spectask'
desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options spec/spec.opts']
  t.spec_files = FileList['spec/**/*_spec.rb']
end


begin
  require 'echoe'
  Echoe.new('fill', File.read('VERSION').chomp) do |p|
    p.description = "Simple DSL for filling (seeding) your database"
    p.url = "http://github.com/iain/fill"
    p.author = "iain"
    p.email = "iain@iain.nl"
    p.ignore_pattern = [ "pkg/*" ]
    p.development_dependencies = []
    p.runtime_dependencies = []
  end
rescue LoadError
end
