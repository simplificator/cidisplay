require 'rubygems'
require 'daemons'
require 'cidisplay'

credentials = YAML.load_file(File.dirname(__FILE__) + '/hudson.yml')
ci_display = CiDisplay.new(credentials)

Daemons.run_proc('cidsiplay.rb') do
  ci_display.publish
  sleep(120)
end