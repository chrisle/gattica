require 'rubygems'
require 'json'

module Gattica
  class Data::CustomMetric
    include Convertible

    attr_reader :id, :name, :index, :scope, :active, :type, :min_value,
                :max_value, :updated, :created

    def initialize(json)
      @id = json['id']
      @name = json['name']
      @index = json['index']
      @scope = json['scope']
      @active = json['active']
      @type = json['type']
      @min_value = json['min_value']
      @max_value = json['max_value']
      @updated = DateTime.parse(json['updated']) if json['updated']
      @created = DateTime.parse(json['created']) if json['created']
    end

  end
end
