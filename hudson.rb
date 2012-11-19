require File.dirname(__FILE__) + '/ci'

class Hudson < CI

  def initialize(credentials, device = '/dev/tty.usbserial')
    @credentials = credentials
    super(device)
  end


  def fetch_failing_jobs
    Net::HTTP.start(host) do |http|
      req = Net::HTTP::Get.new(path)
      req.basic_auth user, password
      response = http.request(req)
      data = JSON.parse(response.body)
      data['jobs'].select do |job|
        job['color'] != 'blue' && job['color'] != 'blue_anime' && job['color'] != 'disabled'
      end
    end
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
