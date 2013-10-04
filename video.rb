#!/usr/bin/env  rvm 1.9 do ruby
require 'argus'
require 'socket'
require 'xmlsimple'
require 'yaml'

require './lib/video_controller.rb'

VideoController.new(ARGV[0] || 1)