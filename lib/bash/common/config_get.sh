#!/usr/bin/env ruby
require 'yaml'

script_dir = File.expand_path File.dirname(__FILE__)
options = YAML.load_file("#{script_dir}/../../../#{ARGV[1]}/config.yaml")

puts options['options'][ARGV[0]]['default']
