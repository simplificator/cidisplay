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
    jobs = fetch_failing_jobs
    board = open_board(@device)
    if jobs.empty?
      board.deliver(ok_message)
      @runner = nil
    else
      jobs.each do |job|
        board.deliver(failure_message)
      end
    end
  end

  private

  def ok_message
    message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_3_NORMAL,
                                :leading => Rdis::LeadingElement::HOLD,
                                :lagging => Rdis::LaggingElement::HOLD)
    message.add(Rdis::ColorElement::GREEN)
    message.add("ALL SYSTEMS GO")
    message
  end

  def failure_message(job)
    message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_3_NORMAL,
                                :leading => Rdis::LeadingElement::CURTAIN_UP,
                                :lagging => Rdis::LaggingElement::HOLD)
    message.add(Rdis::ColorElement::RED)
    message.add(job.name.upcase)
    message
  end
  def fetch_failing_jobs
    jobs = Hudson::Job.list.map do |name|
      Hudson::Job.new(name)
    end.select do |job|
      job.color != 'blue' && job.color != 'blue_anime'
    end
  end

  def open_board(device)
    board = Rdis::Board.new(device)
    board.open
    board
  end

end
