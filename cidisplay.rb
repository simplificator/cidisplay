require 'rubygems'
require 'yaml'
require 'hudson-remote-api'
require 'rdis'
require 'serialport'

class CiDisplay
  COLORS = {'red' => 1, 'red_anime' => 2, 'blue' => 3, 'blue_anime' => 4, 'grey' => 5}

  def initialize(credentials, device = '/dev/tty.usbserial')
    credentials.each do |key, value|
      Hudson[key.to_sym] = value
    end
    @device = device
  end


  def publish
    jobs = fetch_sorted_jobs
    board = open_board(@device)
    board.deliver build_message(jobs)
  end

  private
  def fetch_sorted_jobs
    jobs = Hudson::Job.list.map do |name|
      Hudson::Job.new(name)
    end.sort() do |a, b|
      (COLORS[a.color] || 10) <=> (COLORS[b.color] || 10)
    end
  end

  def open_board(device)
    board = Rdis::Board.new(device)
    board.open
    board
  end

  def build_message(jobs)
    message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_4_NORMAL)
    jobs.each_with_index do |job, index|
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
end


