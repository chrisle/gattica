require 'rubygems'
require 'json'

module Gattica
  class Filter
    include Convertible

    attr_reader :id, :created, :updated, :name, :kind, :type

    def initialize(json)
      @id = json['id']
      @name = json['name']
      @created = DateTime.parse(json['created'])
      @updated = DateTime.parse(json['updated'])
      @kind = json['kind']
      @type = json['type']
    end

  end
end
