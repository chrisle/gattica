require 'rubygems'
require 'json'

module Gattica
  class Goals
    include Convertible

    attr_reader :id, :updated, :title, :account_id, :account_name,
                :profile_id, :web_property_id, :goals

  
    def initialize(json)
      @id = json['id']
      @updated = DateTime.parse(json['updated'])
      @account_id = find_account_id(json)

      @title = json['name']
      @profile_id = json['id']
      @web_property_id = json['webPropertyId']

      # @goals = json.search('ga:goal').collect do |goal| {
      #   active: goal.attributes['active'],
      #   name: goal.attributes['name'],
      #   number: goal.attributes['number'].to_i,
      #   value: goal.attributes['value'].to_f,
      # }
      # end
    end

  end
end
