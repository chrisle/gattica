require 'rubygems'
require 'json'

module Gattica
  class Variant
  	include Convertible

    attr_reader :name, :status, :url, :weight, :won

    def initialize(json)
      @name = json['name']
      @status = json['status']
      @url = json['url']
      @weight = json['weight']
      @won = json['won']
    end

  end
end