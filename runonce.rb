require 'rubygems'
require 'cidisplay'
require File.dirname(__FILE__) + '/hudons'
require File.dirname(__FILE__) + '/semaphore'



device = ARGV[0] || '/dev/tty.usbserial'
puts "Using Device #{device}"

combined = Combined.new(device)
#combined << Hudson.new(YAML.load_file(File.dirname(__FILE__) + '/hudson.yml'), device)
combined << Semaphore.new("77Uce5itpFox641nxXxE", device)
combined.publish
