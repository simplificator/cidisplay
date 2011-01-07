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
      message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_3_NORMAL,
                                  :leading => Rdis::LeadingElement::HOLD,
                                  :lagging => Rdis::LaggingElement::HOLD)
      message.add(Rdis::ColorElement::GREEN)
      message.add("ALL SYSTEMS GO")
      board.deliver(message)
    else
      jobs.each do |job|
        message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_3_NORMAL,
                                    :leading => Rdis::LeadingElement::CURTAIN_UP,
                                    :lagging => Rdis::LaggingElement::CURTAIN_DOWN)
        message.add(Rdis::ColorElement::RED)
        message.add(job.name.upcase)
        board.deliver(message)
        sleep(3)
      end
    end


  end

  private
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
