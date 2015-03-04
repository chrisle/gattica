require 'rubygems'
require 'json'

module Gattica
  class MetaData

    attr_reader :id, :kind, :type, :data_type, :group, :status, :ui_name,
                :app_ui_name, :description, :allowed_in_segments

    def initialize(json)
      @id = json['id']
      @kind = json['kind']
      @type = json['attributes']['type']
      @data_type = json['attributes']['dataType']
      @group = json['attributes']['group']
      @status = json['attributes']['status']
      @ui_name = json['attributes']['uiName']
      @app_ui_name = json['attributes']['appUiName']
      @description = json['attributes']['description']
      @allowed_in_segments = json['attributes']['allowedInSegments']
    end

  end
end