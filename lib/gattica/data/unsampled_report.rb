require 'rubygems'
require 'json'

module Gattica
  class Data::UnsampledReport
    include Convertible

    attr_reader :id, :created, :updated, :title, :start_date, :end_date,
                :metrics, :dimensions, :filters, :segment, :status,
                :download_type

    def initialize(json)
      @id = json['id']
      @created = DateTime.parse(json['created'])
      @updated = DateTime.parse(json['updated'])
      @title = json['title']
      @start_date = json['start-date']
      @end_date = json['end-date']
      @metrics = json['metrics']
      @dimensions = json['dimensions']
      @filters = json['filters']
      @segment = json['segment']
      @status = json['status']
      @download_type = json['downloadType']
    end

  end
end
