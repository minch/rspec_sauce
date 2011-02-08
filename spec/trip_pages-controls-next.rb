#
# Sauce Labs Cross Browser Test for
#
# Trip Pages Controls
#
# TODO:  move as much as possible to a base class or spec_helper
#
require 'spec_helper'

ondemand = load_erb_yaml("ondemand.yml")
browsers = load_erb_yaml("browsers_full.yml")

check_credentials ondemand

browsers[:browsers].each do |browser|

  context "Trip Page Controls" do
    attr_reader :selenium_driver
    alias :page :selenium_driver

    before(:all) do
      @status = true
      @done = true
      @job_name = job_name(__FILE__, browser)
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
        "job-name" => @job_name,
        "max-duration" => max_duration
      }.to_json,           
        :url => ondemand[:url],
        :timeout_in_second => 30

      puts "@job_name:  #{@job_name.inspect}"
    end

    before(:each) do
      selenium_driver.start_new_browser_session
    end

    after(:each) do |example|
      example_status = test_status(example)
      @status = example_status unless example_status
    end

    # The system capture need to happen BEFORE closing the Selenium session
    append_after(:each) do
      Selenium::RSpec::SeleniumTestReportFormatter.capture_system_state(@selenium_driver, self)
      if @done || !@status
        context = get_context browser
        @selenium_driver.set_context context
        puts "sent context: #{context.inspect}"
      end
      @selenium_driver.close_current_browser_session
    end


    it "it should handle click Next button" do
      id = "trip_next_control"
      page.open "/trips/fisherman-s-wharf-in-san-francisco-ca-1"
      page.is_element_present("id=#{id}").should be_true
      page.click id
      page.wait_for_page_to_load # "30000"
      page.is_element_present("id=#{id}").should be_true

      @done = true # Seems weak but let our context setter know we are finished
    end
  end

end
