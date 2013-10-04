#!/usr/bin/env  rvm 1.9 do ruby
require 'net/http'
require 'net/https'
require 'uri'
require 'xmlsimple'
require 'argus'
    
drone = Argus::Drone.new
drone.start
conf = YAML.load_file('build_credentials.yml')
conf_url = conf["url"]
username = conf["username"]
password = conf["password"]
url = URI.parse(conf_url)

puts "fetching build status for rails 3"
response = ''
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.start() do |http|
  req = Net::HTTP::Get.new(url.path)
  req.basic_auth username, password
  response = http.request(req)
end

ccrb_response = XmlSimple.xml_in(response.body)
# puts ccrb_response.inspect
description = ccrb_response["channel"][0]["item"][0]["description"].first
matches = /committed by (.*?) </.match description
committer = matches[1]
title = ccrb_response["channel"][0]["item"][0]["title"].first
puts "build status is: #{title}"
if title =~ /failed/
  puts "build failed. Last commit by #{committer}"
  fail = true
else
  puts 'build passed'
  fail = false
end
# fail = true
if fail
  puts "triggering drone!"
  drone.take_off
  sleep(5)
  drone.hover
  sleep(2)
  drone.led(:blink_green, 0.5, 0)
  sleep 5
  drone.led(:blink_orange, 0.5, 0)
  sleep 5
  drone.led(:blink_red, 0.5, 0)
  sleep 10
  drone.land
  sleep(5)
  drone.stop
  sleep(10)
end





