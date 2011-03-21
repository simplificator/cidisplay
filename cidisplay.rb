require 'rubygems'
require 'yaml'
require 'rdis'
require 'serialport'
require 'json'
require 'net/http'

class CiDisplay
  SUCCESS_TEXTS = [ 'YESSS', 'THANKS', 'GREAT', 'YOU ROCK', 'AGAIN', 'NIFTY', 'GREEN',
                    'WARP 9', 'SUPERB', 'HOORAY', 'WORKING', 'RUNNING', 'READY!',
                    'SOLID!', 'NICE!', 'TATAAA', 'GOOD', 'WOW', 'STABLE', '--OK--', 'PERFECT']

  def initialize(credentials, device = '/dev/tty.usbserial')
    @credentials = credentials
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

  private

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

  def fetch_failing_jobs
    Net::HTTP.start(host) do |http|
      req = Net::HTTP::Get.new(path)
      req.basic_auth user, password
      response = http.request(req)
      data = JSON.parse(response.body)
      data['jobs'].select do |job|
        job['color'] != 'blue' && job['color'] != 'blue_anime' job['color'] != 'disabled'
      end
    end
  end

  def open_board(device)
    board = Rdis::Board.new(device)
    board.open
    board
  end


  private

  def user
    @credentials['user']
  end

  def password
    @credentials['password']
  end

  def host
    @credentials['host']
  end

  def view
    @credentials['view'] || 'All'
  end

  def path
    "/view/#{view}/api/json"
  end

end
