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
require 'gattica/hash_extensions'
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
  
  VERSION = '0.6.2'
  
  # Creates a new instance of Gattica::Engine
  def self.new(*args)
    Engine.new(*args)
  end
  
end
