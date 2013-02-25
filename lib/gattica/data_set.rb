module Gattica
  
  # Encapsulates the data returned by the GA API
  class DataSet
    include Convertible
    attr_reader :total_results, :start_date, :end_date, :xml
    attr_accessor :start_index, :items_per_page, :points

    def initialize(xml, args, engine)
      @xml = xml.to_s
      @args = args
      @engine = engine
      @total_results = xml.at('openSearch:totalResults').inner_html.to_i
      @start_index = xml.at('openSearch:startIndex').inner_html.to_i
      @items_per_page = xml.at('openSearch:itemsPerPage').inner_html.to_i
      @start_date = Date.parse(xml.at('dxp:startDate').inner_html)
      @end_date = Date.parse(xml.at('dxp:endDate').inner_html)
      @points = xml.search(:entry).collect { |entry| DataPoint.new(entry) }
    end

    def next_page?
      in_bounds? current_page + 1
    end

    def previous_page?
      in_bounds? current_page - 1
    end

    def next_page
      page current_page + 1
    end

    def previous_page
      page current_page - 1
    end

    def page(number)
      return nil unless in_bounds? number
      @engine.get @args.merge start_index: (number - 1) * per_page + 1
    end

    def total_pages
      (total_results / items_per_page.to_f).ceil
    end

    def current_page
      (start_index / items_per_page) + 1
    end

    alias_method :per_page, :items_per_page
    alias_method :total_entries, :total_results

    # Returns a string formatted as a CSV containing just the data points.
    #
    # == Parameters:
    # +format=:long+::    Adds id, updated, title to output columns
    def to_csv(format=:short)
      output = ''
      columns = []
      case format
        when :long
          ["id", "updated", "title"].each { |c| columns << c }
      end
      unless @points.empty?   # if there was at least one result
        @points.first.dimensions.map {|d| d.keys.first}.each { |c| columns << c }
        @points.first.metrics.map {|m| m.keys.first}.each { |c| columns << c }
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
        'points' => @points }.to_yaml
    end

    def to_hash
      @points.map(&:to_hash)
    end

    protected

    def in_bounds?(number)
      number > 0 && number <= total_pages
    end
  end
  
end
