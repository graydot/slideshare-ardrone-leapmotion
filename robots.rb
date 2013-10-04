#!/usr/bin/env  rvm 1.9 do ruby
require 'artoo'
require 'artoo-leapmotion'
require 'argus'
require './lib/gesture_controller.rb'
require './lib/gesture.rb'
require './lib/hand_controller.rb'
require './lib/hand.rb'
require './lib/drone.rb'


# TODOS
# make leapmotion better
# food delivery?
# ping?
connection :leapmotion, :adaptor => :leapmotion, :port => '127.0.0.1:6437'
device :leapmotion, :driver => :leapmotion

work do
  $q = nil
  drone = nil
  drone = Argus::Drone.new
  $dr = Drone.new(drone)
  $hc = HandController.new
  $thread = Thread.new do
    activity = nil
    lock = false
    while true
      curr_time = Time.now
      if $q
        new_activity, duration = $q
        $q = nil
        activity = new_activity
        end_time = curr_time + duration if duration
      end
      if end_time && curr_time > end_time
        puts "ending previous"
        drone.hover rescue nil
        end_time = nil
      end
      
      if activity == :lock
        drone.hover rescue nil
        lock = true
      end
      
      if activity == :unlock
        lock = false
      end
      if activity && !lock
        activity = activity.to_sym
        puts activity
        if [:lock, :unlock].include? activity
          # do nothing
        elsif [:up, :down].include? activity
          drone.send(activity, 0.2) rescue nil
        elsif [:turn_left, :turn_right, :left, :right, :forward, :backward].include? activity
          drone.send(activity, 0.1) rescue nil
        else
          drone.send(activity) rescue nil
        end
        activity = nil
      end
      sleep(0.1)
    end
  end
  
  $thread.abort_on_exception = true
  
  on leapmotion, :open => :on_open
  on leapmotion, :frame => :on_frame
  on leapmotion, :close => :on_close
end

def on_open(*args)
  
end
def on_frame(*args)
  frame = args[1]

  if frame.hands.length > 0
    $hc.process_hands(frame.hands)
  end
end

def on_close(*args)
  # puts args
end

