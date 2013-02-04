require File.dirname(__FILE__) + '/ci'
class Semaphore < CI

  def initialize(credentials)
    @credentials = credentials
  end

  def fetch_failing_jobs
    http = Net::HTTP.new(host, 443)
    http.use_ssl = true
    response, data = http.get(path)
    all = JSON.parse(response.body)
    # map all branches and flatten... so we only loop branches which is the equivalent of jenkins jobs
    all_branches = all.map { |project| project['branches'] }.flatten
    # only failed once are interesting...
    failed = all_branches.select { |branch| branch['result'] == 'failed' }
    as_jobs = failed.map { |branch| {'name' => "#{branch['project_name']} (#{branch['branch_name']})" } }
    as_jobs
  end


  def path
    "/api/v1/projects?auth_token=#{@credentials}"
  end

  def host
    "semaphoreapp.com"
  end
end