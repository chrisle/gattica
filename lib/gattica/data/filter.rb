require 'rubygems'
require 'json'

module Gattica
  class Data::Filter
    include Convertible

    attr_reader :id, :account_id, :created, :updated, :name, :type

    def initialize(json)
      @id = json['id']
      @account_id = json['accountId']
      @name = json['name']
      @created = DateTime.parse(json['created'])
      @updated = DateTime.parse(json['updated'])
      @type = json['type']
    end

  end
end
