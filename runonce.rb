require 'rubygems'
require 'ci'
require File.dirname(__FILE__) + '/hudson'

require File.dirname(__FILE__) + '/semaphore'
require File.dirname(__FILE__) + '/combined'




combined = Combined.new()
combined << Hudson.new(YAML.load_file(File.dirname(__FILE__) + '/hudson.yml'))
combined << Semaphore.new("77Uce5itpFox641nxXxE")
devices_string = ARGV[0] || '/dev/tty.usbserial'
puts "Using Device #{devices_string}"
jobs = combined.fetch_failing_jobs
devices_string.split(',').each do |device|
  combined.publish(jobs, device)
end
