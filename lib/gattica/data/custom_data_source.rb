require 'rubygems'
require 'json'

module Gattica
  class Data::CustomDataSource
    include Convertible

    attr_reader :id, :name, :description, :type, :upload_type, :import_behavior,
                :updated, :created

    def initialize(json)
      @id = json['id']
      @name = json['name']
      @type = json['index']
      @description = json['description']
      @upload_type = json['upload_type']
      @import_behavior = json['import_behavior']
      @updated = DateTime.parse(json['updated']) if json['updated']
      @created = DateTime.parse(json['created']) if json['created']
    end

  end
end
