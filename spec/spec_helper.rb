require 'rubygems'
require 'json'
require 'selenium/client'
require 'selenium/rspec/spec_helper'
require 'net/http'
require 'yaml'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["spec/support/**/*.rb"].each {|f| require f}

