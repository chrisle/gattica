module Gattica
  
  # Encapsulates the data returned by the GA API
  class DataSet
    include Convertible

    attr_reader :total_results, :start_index, :items_per_page, :start_date,
                :end_date, :points, :xml, :sampled_data, :total_for_all_results, :headers

    def initialize(json)
      @xml = json.to_s
      @total_results = json['totalResults'].to_i
      @start_index = json['query']['start-index'].to_i
      @items_per_page = json['itemsPerPage'].to_i
      @start_date = Date.parse(json['query']['start-date'])
      @end_date = Date.parse(json['query']['end-date'])
      @sampled_data = json['containsSampledData']
      @total_for_all_results = json['totalsForAllResults']
      headers = []
      json['columnHeaders'].each { |column| headers << column['name'].gsub('ga:','').to_sym }
      @headers = headers
      columns = []
      json['rows'].each { |entry| columns << Hash[headers.zip(entry)] } if json['rows']
      @points = columns
    end

    # Returns a string formatted as a CSV containing just the data points.
    #
    # == Parameters:
    # +format=:long+::    Adds id, updated, title to output columns
    def to_csv(format=:short)
      output = ''
      columns = []
      case format
        when :long
          ['id', 'updated', 'title'].each { |c| columns << c }
      end
      unless @points.empty?   # if there was at least one result
        @points.first.map {|d| columns << d.keys }
      end
      output = CSV.generate_line(columns) 
      @points.each do |point|
        output += point.to_csv(format)
      end
      output
    end

    def to_yaml
      { 'total_results' => @total_results,
        'start_index' => @start_index,
        'items_per_page' => @items_per_page,
        'start_date' => @start_date,
        'end_date' => @end_date,
        'sampled_data' => @sampled_data,
        'points' => @points,
        'total_for_all_results' => @total_for_all_results }.to_yaml
    end

    def to_hash
      @points.map(&:to_hash)
    end

  end

end