#!/usr/bin/env ruby
require_relative 'lib/medusa_copier'

#only run if given run as the first argument. This is useful for letting us load this file
#in irb to work with things interactively when we need to
MedusaCopier.new(config_file: 'config/medusa_copier.yaml').run if ARGV[0] == 'run'
