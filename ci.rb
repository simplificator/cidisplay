require 'rubygems'
require 'yaml'
require 'rdis'
require 'serialport'
require 'json'

require 'net/http'
require 'net/https'



class CI
  SUCCESS_TEXTS = [ 'YESSS', 'THANKS', 'GREAT', 'YOU ROCK', 'AGAIN', 'NIFTY', 'GREEN',
                    'WARP 9', 'SUPERB', 'HOORAY', 'WORKING', 'RUNNING', 'READY!',
                    'SOLID!', 'NICE!', 'TATAAA', 'GOOD', 'WOW', 'STABLE', '--OK--', 'PERFECT']

  def initialize(device = '/dev/tty.usbserial')
    @device = device
  end


  def publish
    jobs = fetch_failing_jobs
    board = open_board(@device)
    if jobs.empty?
      board.deliver(ok_message)
    else
      board.deliver(failure_message(jobs))
    end
  end


  def ok_message
    message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_3_NORMAL,
                                :leading => Rdis::LeadingElement::CURTAIN_UP,
                                :lagging => Rdis::LaggingElement::HOLD)
    message.add(Rdis::ColorElement::GREEN)
    text = Time.now.strftime("%H:%M ") + SUCCESS_TEXTS[Time.now.min % SUCCESS_TEXTS.length]
    message.add(text)
    message
  end

  def failure_message(jobs)
    message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_3_NORMAL,
                                :leading => Rdis::LeadingElement::SCROLL_LEFT,
                                :lagging => Rdis::LaggingElement::SCROLL_LEFT)
    message.add(Rdis::ColorElement::RED)

    text = jobs.map {|job| job['name'].upcase }.join(" | ")
    message.add(text)
    message
  end

  def open_board(device)
    board = Rdis::Board.new(device)
    board.open
    board
  end

end