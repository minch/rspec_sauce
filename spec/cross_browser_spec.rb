#
# Sauce Labs Cross Browser Test for
#
# TODO:
#
# 1. Move everything to shared spec example groups.
#
# 2. Once the above is complete then move each view context group of examples
# to its own spec.
#
require 'spec_helper'

ondemand = load_erb_yaml("ondemand.yml")
browsers = load_erb_yaml("browsers_full.yml")

check_credentials ondemand

browsers[:browsers].each do |browser|

  context "Cross Browser" do
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
        :timeout_in_second => default_timeout_seconds

      puts "@job_name:  #{@job_name.inspect}"
    end

    before(:each) do
      selenium_driver.start_new_browser_session
      selenium_driver.set_timeout default_timeout_milliseconds
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

    context "Trip Pages" do
      context "Show" do

        context "Controls" do
          it "it should handle click Next button" do
            id = "trip_next_control"
            page.open "/trips/fisherman-s-wharf-in-san-francisco-ca-1"
            page.wait_for_page_to_load # "30000"
            handle_giveaway_popup
            page.is_element_present("id=#{id}").should be_true
            page.click id
            page.wait_for_page_to_load # "30000"
            page.is_element_present("id=#{id}").should be_true

            @done = true # Seems weak but let our context setter know we are finished
          end

        end
      end
    end

    context "Destinations" do
      context "Show" do

        it "it should render the show view" do
          finder = "class=viewport"
          url = "/destinations/new-smyrna-beach-fl"

          page.open url
          page.wait_for_page_to_load
          handle_giveaway_popup
          page.is_element_present(finder).should be_true
        end

      end
    end

    context "Tags" do
      context "Show" do

        it "it should render the show view" do
          finder = "class=viewport"
          url = "/tags/culinary"

          page.open url
          page.wait_for_page_to_load
          handle_giveaway_popup
          page.is_element_present(finder).should be_true
        end

      end
    end

    context "Account" do

      context "Signup and Signin" do
        it "it should render lightbox" do
          url = "/tags/culinary?foo=sign_in_up"
          condition = "selenium.browserbot.getCurrentWindow().document.getElementById('loginscreen-tab-list')"

          page.open url
          page.wait_for_page_to_load
          handle_giveaway_popup
          page.click "link=Sign In"
          page.wait_for_condition condition 
        end
      end

    end

    context "Pois" do

      context "Show" do
        it "it should render the show view" do
          finder = "class=photo_container"
          url = "/inns/the-foley-house-inn-in-savannah-ga"

          page.open url
          page.wait_for_page_to_load
          handle_giveaway_popup
          page.is_element_present(finder).should be_true
        end
      end

    end

  end # End Cross Browser context

  def handle_giveaway_popup
    locator = popup_element_locator
    page.click locator if check_for_element locator
  end

  def popup_element_locator
    "id=#{popup_element_id}"
  end

  def popup_element_id
    "x-close-giveaway-popup"
  end

  def check_for_element(locator)
    retries = 3
    sleep_time = 1
    script = "var document = selenium.browserbot.getCurrentWindow().document;"
    script += "var element = document.getElementById('#{popup_element_id}');"
    script += "typeof(element);"

    retries.times do
      eval_d = page.get_eval(script)
      is_present = eval_d == 'object'
      return true if is_present

      sleep sleep_time
    end

    return false
  end
end

