require 'recursive-open-struct'
require 'rbconfig'
require 'json'
require 'yaml'
require 'colorize'

module Bmjones
	class ConfigurationError < StandardError
	end

	unless File.exists? 'config.yaml'
		raise ConfigurationError, 'config.yaml is missing. see config.example.yaml'
	end

	CONFIG ||= RecursiveOpenStruct.new YAML.load_file('./config.yaml')
end

