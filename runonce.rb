require 'rubygems'
require 'daemons'
require 'cidisplay'

device = ARGV[1] || '/dev/tty.usbserial'
puts "Using Device #{device}"
credentials = YAML.load_file(File.dirname(__FILE__) + '/hudson.yml')
ci_display = CiDisplay.new(credentials, device)
ci_display.publish
