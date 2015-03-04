require 'rubygems'
require 'json'

module Gattica
  class Experiment

    attr_reader :id, :account_id, :created, :editable_in_ga_ui, :description,
                :end_time, :equal_weighting, :internal_web_property_id, :kind,
                :minimum_experiment_length_in_days, :name, :objective_metric,
                :optimization_type, :profile_id, :reason_experiment_ended,
                :rewrite_variation_urls_as_original, :self_link,
                :serving_framework, :snippet, :start_time, :status,
                :traffic_coverage, :updated, :web_property_id,
                :winner_confidence_level, :winner_found, :variations

    def initialize(json)
      @id = json['id']
      @account_id = json['accountId']
      @created = DateTime.parse(json['created'])
      @editable_in_ga_ui = json['editableInGaUi']
      @description = json['description']
      @end_time = DateTime.parse(json['endTime']) if json['endTime']
      @equal_weighting = json['equalWeighting']
      @internal_web_property_id = json['internalWebPropertyId']
      @kind = json['kind']
      @minimum_experiment_length_in_days = json['minimumExperimentLengthInDays']
      @name = json['name']
      @objective_metric = json['objectiveMetric']
      @optimization_type = json['optimizationType']
      @profile_id = json['profileId']
      @reason_experiment_ended = json['reasonExperimentEnded']
      @rewrite_variation_urls_as_original = json['rewriteVariationUrlsAsOriginal']
      @self_link = json['selfLink']
      @serving_framework = json['servingFramework']
      @snippet = json['snippet']
      @start_time = DateTime.parse(json['startTime'])
      @status = json['status']
      @traffic_coverage = json['trafficCoverage']
      @updated = DateTime.parse(json['updated'])
      @web_property_id = json['webPropertyId']
      @winner_confidence_level = json['winnerConfidenceLevel']
      @winner_found = json['winnerFound']
      @variations = json['variations'].collect { |variant| Variant.new(variant) }
    end

  end
end