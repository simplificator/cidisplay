require File.dirname(__FILE__) + '/ci'

class Combined < CI
  def initialize(credentials, device = '/dev/tty.usbserial')
    @cis = []
    super(device)
  end

  def <<(ci)
    @cis << ci
  end

  def fetch_failing_jobs
    @cis.map(&:fetch_failing_jobs).flatten
  end

end