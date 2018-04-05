# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tag_qc_tool/version'

Gem::Specification.new do |spec|
  spec.name          = 'gatekeeper'
  spec.version       = Gatekeeper::VERSION
  spec.authors       = ['James Glover']
  spec.email         = ['jg16@sanger.ac.uk']
  spec.summary       = 'A tool to manage QC of tag plate batches for the LIMS Sequencescape.'
  spec.description   = 'Gatekeeper is used to track the production and validation of batches of tag plates for Sequencing. It is designed to interface with the LIMS Sequencescape.'
  spec.homepage      = 'http://www.github.com/sanger'
  spec.license       = 'GNU GPL'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
