lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'fedex_api'
  s.version       = '0.0.1'
  s.authors       = ['Sinfin']
  s.email         = ['martin.dedek@sinfin.cz', 'info@sinfin.cz']
  s.homepage      = 'http://sinfin.digital'
  s.summary       = 'A wrapper for Fedex Web Services API'
  s.description   = 'A wrapper for Fedex Web Services API'
  s.license       = 'MIT'
  s.files         = Dir[ 'lib/**/*' ]
  s.test_files    = Dir[ 'test/**/*' ]
  s.require_paths = [ 'lib' ]

  s.add_dependency 'savon', '~> 2.0'

  s.add_development_dependency 'bundler', '~> 2.0'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'dotenv'
  s.add_development_dependency 'pry'
end
