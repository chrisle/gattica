require 'rubygems'
require 'json'

module Gattica
  class Data::UnsampledReport
    include Convertible

    attr_reader :id, :created, :updated, :title, :start_date, :end_date,
                :metrics, :dimensions, :filters, :segment, :status,
                :download_type, :account_id, :web_property_id, :profile_id,
                :drive_download_details

    def initialize(json)
      @id = json['id']
      @created = DateTime.parse(json['created'])
      @updated = DateTime.parse(json['updated'])
      @account_id = json['accountId']
      @web_property_id = json['webPropertyId']
      @profile_id = json['profileId']
      @title = json['title']
      @start_date = json['start-date']
      @end_date = json['end-date']
      @metrics = json['metrics']
      @dimensions = json['dimensions']
      @filters = json['filters']
      @segment = json['segment']
      @status = json['status']
      @download_type = json['downloadType']
      @drive_download_details = json['driveDownloadDetails']
    end

  end
end
