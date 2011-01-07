require 'rubygems'
require 'yaml'
require 'hudson-remote-api'
require 'rdis'
require 'serialport'

credentials = YAML.load_file(File.dirname(__FILE__) + '/hudson.yml')
credentials.each do |key, value|
  puts "#{key} => #{value}"
  Hudson[key.to_sym] = value
end




COLORS = {'red' => 1, 'red_anime' => 2, 'blue' => 3, 'blue_anime' => 4, 'grey' => 5}

def fetch_sorted_jobs
  jobs = Hudson::Job.list.map do |name|
    Hudson::Job.new(name)
  end.sort() do |a, b|
    (COLORS[a.color] || 10) <=> (COLORS[b.color] || 10)
  end
end

def open_board()
  board = Rdis::Board.new('/dev/tty.usbserial')
  board.open
  board
end
def build_message(jobs)
  message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_1_NORMAL)
  jobs.each_with_index do |job|
    case job.color
    when 'red'
      message.add(Rdis::ColorElement::RED)
      add_job_name(message, job, index)
    when 'red_anime'
      message.add(Rdis::ColorElement::DIM_RED)
      add_job_name(message, job, index)
    when 'blue'
      message.add(Rdis::ColorElement::GREEN)
      add_job_name(message, job, index)
    when 'blue_anime'
      message.add(Rdis::ColorElement::DIM_GREEN)
      add_job_name(message, job, index)
    when 'grey'
      message.add(Rdis::ColorElement::YELLOW)
      add_job_name(message, job, index)
    else
      message.add(Rdis::ColorElement::RAINBOW)
      add_job_name(message, job, index)
    end
  end
  message
end

def add_job_name(message, job, index)
  if index > 0
    message.add " | "
  end
  message.add(job.name)
end

run = true
while run
  puts "Reading data"
  jobs = fetch_sorted_jobs
  puts "Got info about #{jobs.size} jobs"
  board = open_board
  puts "Board opened"
  board.deliver build_message(jobs)
  puts "All messages delivered to board"
 # run = false
  sleep 120
end


