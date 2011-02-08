require 'rubygems'
require 'json'
require 'selenium/client'
require 'selenium/rspec/spec_helper'
require 'net/http'
require 'yaml'

def test_name(name)
  name = name.first
  name = File.basename(name)
  name.sub(/\.rb$/, '')
end

def get_context(browser)
  "sauce:job-info={\"name\": \"#{@job_name}\"," + "\"passed\": #{@status}}"
end

def job_name(name, browser)
  name = [ test_name(name) ]
  name.push test_name(name)
  [:name, :version, :os].each do |s|
    name.push(browser[s])
  end
  name.push Time.now.utc.to_i

  name.join('-')
end

def test_status(example)
  execution_error = example.execution_error
  execution_error ? false : true
end

def max_duration
  30
end

def check_credentials(h)
  [:username, :api_key].each do |s|
    prefix = 'SL_'
    tmp = s.to_s.upcase.sub(/^#{prefix}/, '')
    unless h[s]
      puts "Please specify ENV['#{prefix}#{tmp}']"
      exit 1
    end
  end
end

def load_erb_yaml(path)
  YAML.load(ERB.new(File.read(path)).result)
end
