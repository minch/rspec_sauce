shared_examples_for "cross-browser example" do
  before(:all) do
    browser = @@browser
    ondemand = @@ondemand
    @@status = true
    @@done = true
    @@job_name = job_name(@@test_name, browser)
    @selenium_driver = Selenium::Client::Driver.new \
      :host => "saucelabs.com",
      :port => 4444,
      :browser => 
    {
      "username" => ondemand[:username],
      "access-key" => ondemand[:api_key],
      "os" => browser[:os],
      "browser" => browser[:name],
      "browser-version" => browser[:version],
      "job-name" => @@job_name,
      "max-duration" => max_duration
    }.to_json,           
      :url => ondemand[:url],
      :timeout_in_second => 30

    puts "@@job_name:  #{@@job_name.inspect}"
  end

  before(:each) do
    @selenium_driver.start_new_browser_session
  end

  after(:each) do |example|
    example_status = test_status(example)
    @@status = example_status unless example_status
    @@done = true
  end

  # The system capture need to happen BEFORE closing the Selenium session
  append_after(:each) do
    Selenium::RSpec::SeleniumTestReportFormatter.capture_system_state(@selenium_driver, self)
    if @@done || !@@status
      context = get_context @@browser
      @selenium_driver.set_context context
      puts "sent context: #{context.inspect}"
    end
    @selenium_driver.close_current_browser_session
  end
end
