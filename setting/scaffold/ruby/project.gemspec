# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'project'
  spec.version = '0.1.0'
  spec.summary = 'A Ruby project'
  spec.authors = ['Project contributors']
  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
