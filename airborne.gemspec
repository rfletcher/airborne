require "time"

Gem::Specification.new do |s|
  s.name          = 'airborne'
  s.version       = '0.2.7'
  s.date          = Date.today.to_s
  s.summary       = 'RSpec driven API testing framework'
  s.authors       = ['Alex Friedman', 'Seth Pollack']
  s.email         = ['a.friedman07@gmail.com', 'teampollack@gmail.com']
  s.require_paths = ['lib']
  s.files         = `git ls-files`.split("\n")
  s.license       = 'MIT'
  s.add_runtime_dependency 'rspec', '~> 3.1'
  s.add_runtime_dependency 'rest-client', '< 3.0', '>= 2.0.0'
  s.add_runtime_dependency 'rack-test', '~> 0.6', '>= 0.6.2'
  s.add_runtime_dependency 'rack', '< 2.0' # for Ruby < 2.2
  s.add_runtime_dependency 'activesupport', '< 5.0', '>= 3.0'
  s.add_runtime_dependency 'rkelly-remix', '~> 0.0.7'
  s.add_development_dependency 'webmock', '~> 0'
end
