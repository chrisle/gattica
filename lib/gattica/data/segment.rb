require 'rubygems'
require 'json'

module Gattica
  class Data::Segment
    include Convertible

    attr_reader :id, :name, :definition, :updated, :created

    def initialize(json)
      @id = json['id']
      @name = json['name']
      @definition = json['definition']
      @updated = DateTime.parse(json['updated']) if json['updated']
      @created = DateTime.parse(json['created']) if json['created']
    end

  end
end
