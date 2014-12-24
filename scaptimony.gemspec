$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'scaptimony/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'scaptimony'
  s.version     = Scaptimony::VERSION
  s.authors     = ['Šimon Lukašík']
  s.email       = ['slukasik@redhat.com']
  s.homepage    = 'https://github.com/OpenSCAP/scaptimony'
  s.summary     = 'SCAPtimony is SCAP database and storage server'
  s.description = "SCAPtimony is SCAP storage and database server build on top
    of OpenSCAP library. SCAPtimony can be deployed as a part of your Rails
    application (i.e. Foreman) or as a stand-alone sealed server."
  s.license     = 'GPL-3.0'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['COPYING', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 3.2.8'
  s.add_dependency 'openscap', '>= 0.4.0'

  s.add_development_dependency 'sqlite3'
end
