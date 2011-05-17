$:.unshift File.dirname(__FILE__) # for use/testing when no gem is installed

require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'logger'
require 'rubygems'
require 'hpricot'
require 'yaml'

require 'gattica/engine'
require 'gattica/settings'
require 'gattica/version'
require 'gattica/core_extensions'
require 'gattica/convertible'
require 'gattica/exceptions'
require 'gattica/user'
require 'gattica/auth'
require 'gattica/account'
require 'gattica/data_set'
require 'gattica/data_point'
require 'gattica/segment'

# Gattica is a Ruby library for talking to the Google Analytics API.
# Please see the README for usage docs.
module Gattica
  
  VERSION = '0.4.3'
  
  # Creates a new instance of Gattica::Engine and gets us going. Please see the README for usage docs.
  #   ga = Gattica.new({:email => 'anonymous@anon.com', :password => 'password, :profile_id => 123456 })
  
  def self.new(*args)
    Engine.new(*args)
  end
  
end
