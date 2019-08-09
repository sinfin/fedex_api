lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'fedex_api'
  s.version       = '0.0.1'
  s.authors       = ['Sinfin']
  s.email         = ['info@sinfin.cz']
  s.homepage      = 'http://sinfin.digital'
  s.summary       = 'Summary of FedexApi.'
  s.description   = 'Description of FedexApi.'
  s.license       = 'MIT'
  s.files         = Dir[ "lib/**/*" ]
  s.require_paths = [ 'lib' ]

  s.add_dependency 'savon', '~> 2.0'
end
