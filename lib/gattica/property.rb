require 'rubygems'
require 'json'

module Gattica
  class Property
    include Convertible

    attr_reader :id, :kind, :created, :updated, :industry_vertical,
                :level, :name, :profile_count

    def initialize(json)
      @id = json['id']
      @kind = json['kind']
      @created = DateTime.parse(json['created'])
      @updated = DateTime.parse(json['updated'])
      @industry_vertical = json['industryVertical']
      @level = json['level']
      @name = json['name']
      @profile_count = json['profileCount']
    end

  end
end