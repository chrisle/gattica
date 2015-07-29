require 'rubygems'
require 'json'

module Gattica
  class Data::Property
    include Convertible

    attr_reader :id, :kind, :created, :updated, :industry_vertical,
                :level, :name, :profile_count, :account_id, :web_property_id

    def initialize(json)
      @id = json['id']
      @account_id = json['accountId']
      @web_property_id = json['internalWebPropertyId']
      @default_profile_id = json['defaultProfileId']
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
