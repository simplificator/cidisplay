require 'rubygems'
require 'rdis'
require 'serialport'

  def deliver(device)
    board = Rdis::Board.new(device)
    board.open

    message = Rdis::Message.new(:method => Rdis::DisplayMethodElement::LEVEL_3_NORMAL,
                                :leading => Rdis::LeadingElement::CURTAIN_UP,
                                :lagging => Rdis::LaggingElement::HOLD)
    message.add(Rdis::ColorElement::GREEN)
    message.add("Hooooray")

    board.deliver(message)
  end



deliver('/dev/tty.usbserial')