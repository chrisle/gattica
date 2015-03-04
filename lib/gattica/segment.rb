require 'rubygems'
require 'json'

module Gattica
  class Segment
    include Convertible

    attr_reader :id, :name, :definition, :updated

    def initialize(json)
      @id = json['id']
      @name = json['name']
      @definition = json['definition']
      @updated = DateTime.parse(json['updated']) if json['updated']
    end

  end
end