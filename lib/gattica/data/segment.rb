require 'rubygems'
require 'json'

module Gattica
  class Data::Segment
    include Convertible

    attr_reader :id, :name, :definition, :updated, :created, :segment_id, :type

    def initialize(json)
      @id = json['id']
      @segment_id = json['segmentId']
      @name = json['name']
      @definition = json['definition']
      @type = json['type']
      @updated = DateTime.parse(json['updated']) if json['updated']
      @created = DateTime.parse(json['created']) if json['created']
    end

  end
end
