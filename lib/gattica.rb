$:.unshift File.dirname(__FILE__) # For use/ testing when no gem is installed

require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'logger'
require 'rubygems'
require 'yaml'
require 'json'
require 'openssl'
require 'stringio'
require 'zlib'

require 'gattica/engine'
require 'gattica/settings'
require 'gattica/convertible'
require 'gattica/hash_extensions'
require 'gattica/data_set'
require 'gattica/meta_data'
require 'gattica/exceptions'
require 'gattica/data/account'
require 'gattica/data/upload'
require 'gattica/data/segment'
require 'gattica/data/experiment'
require 'gattica/data/variant'
require 'gattica/data/profile'
require 'gattica/data/property'
require 'gattica/data/goal'
require 'gattica/data/filter'
require 'gattica/data/custom_metric'
require 'gattica/data/custom_dimension'
require 'gattica/data/custom_data_source'
require 'gattica/data/unsampled_report'

# Gattica is a Ruby library for talking to the Google Analytics API.
# Please see the README for usage docs.
module Gattica

  VERSION = '1.5.7'

  # Creates a new instance of Gattica::Engine
  def self.new(*args)
    Engine.new(*args)
  end

end
