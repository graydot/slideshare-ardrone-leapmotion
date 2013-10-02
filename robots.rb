#!/usr/bin/env  rvm 1.9 do ruby
require 'artoo'
require 'artoo-leapmotion'
require 'artoo-ardrone'

connection :leapmotion, :adaptor => :leapmotion, :port => '127.0.0.1:6437'
device :leapmotion, :driver => :leapmotion

work do
  on leapmotion, :open => :on_open
  on leapmotion, :frame => :on_frame
  on leapmotion, :close => :on_close
end

def on_open(*args)
  puts args
end

def on_frame(*args)
  frame = args[1]
  puts frame
  puts frame.hands
  puts frame.gestures
  puts frame.pointables
end

def on_close(*args)
  puts args
end
