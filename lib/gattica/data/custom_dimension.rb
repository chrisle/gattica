require 'rubygems'
require 'json'

module Gattica
  class Data::CustomMetric
    include Convertible

    attr_reader :id, :name, :index, :scope, :active, :updated, :created,
                :account_id, :web_property_id

    def initialize(json)
      @id = json['id']
      @account_id = json['accountId']
      @web_property_id = json['webPropertyId']
      @name = json['name']
      @index = json['index']
      @scope = json['scope']
      @active = json['active']
      @updated = DateTime.parse(json['updated']) if json['updated']
      @created = DateTime.parse(json['created']) if json['created']
    end

  end
end
