module Gattica
  class Engine

    attr_reader :user
    attr_accessor :profile_id, :token, :user_accounts

    # Initialize Gattica using username/password or token.
    #
    # == Options:
    # To change the defaults see link:settings.rb
    # +:debug+::        Send debug info to the logger (default is false)
    # +:headers+::      Add additional HTTP headers (default is {} )
    # +:logger+::       Logger to use (default is STDOUT)
    # +:profile_id+::   Use this Google Analytics profile_id (default is nil)
    # +:timeout+::      Set Net:HTTP timeout in seconds (default is 300)
    # +:token+::        Use an authentication token you received before
    # +:api_key+::      The Google API Key for your project
    # +:verify_ssl+::   Verify SSL connection (default is true)
    # +:ssl_ca_path+::  PATH TO SSL CERTIFICATES to see this run on command line:(openssl version -a) ubuntu path eg:"/usr/lib/ssl/certs"
    # +:proxy+::        If you need to pass over a proxy eg: proxy => { host: '127.0.0.1', port: 3128 }
    def initialize(options={})
      @options = Settings::DEFAULT_OPTIONS.merge(options)
      handle_init_options(@options)
      create_http_connection('www.google.com')
      check_init_auth_requirements()
    end

    # Returns the list of accounts the user has access to. A user may have
    # multiple accounts on Google Analytics and each account may have multiple
    # profiles. You need the profile_id in order to get info from GA. If you
    # don't know the profile_id then use this method to get a list of all them.
    # Then set the profile_id of your instance and you can make regular calls
    # from then on.
    #
    #   ga = Gattica.new({token: 'oauth2_token'})
    #   ga.accounts
    #   # you parse through the accounts to find the profile_id you need
    #   ga.profile_id = 12345678
    #   # now you can perform a regular search, see Gattica::Engine#get
    #
    # If you pass in a profile id when you instantiate Gattica::Search then you won't need to
    # get the accounts and find a profile_id - you apparently already know it!
    #
    # See Gattica::Engine#get to see how to get some data.

    def accounts
      if @user_accounts.nil?
        create_http_connection('www.googleapis.com')

        # Get profiles
        response = do_http_get("/analytics/v3/management/accounts/~all/webproperties/~all/profiles?max-results=10000&fields=items(id,name,updated,accountId,webPropertyId,eCommerceTracking,currency,timezone,siteSearchQueryParameters)")
        json = decompress_gzip(response)
        @user_accounts = json['items'].collect { |profile_json| Account.new(profile_json) }

        # Fill in the goals
        response = do_http_get("/analytics/v3/management/accounts/~all/webproperties/~all/profiles/~all/goals?max-results=10000&fields=items(profileId,name,value,active,type,updated)")
        json = decompress_gzip(response)
        @user_accounts.each do |ua|
          json['items'].each { |e| ua.set_goals(e) }
        end unless (json.blank?)

        # Fill in the account name
        response = do_http_get("/analytics/v3/management/accounts?max-results=10000&fields=items(id,name)")
        json = decompress_gzip(response)
        @user_accounts.each do |ua|
          json['items'].each { |e| ua.set_account_name(e) }
        end

      end
      @user_accounts
    end

    # Returns the list of segments available to the authenticated user.
    #
    # == Usage
    #   ga = Gattica.new({token: 'oauth2_token'})
    #   ga.segments                       # Look up segment id
    #   my_gaid = 'gaid::-5'              # Non-paid Search Traffic
    #   ga.profile_id = 12345678          # Set our profile ID
    #
    #   ga.get({ start_date: '2008-01-01',
    #            end_date: '2008-02-01',
    #            dimensions: 'month',
    #            metrics: 'views',
    #            segment: my_gaid })

    def segments
      if @user_segments.nil?
        create_http_connection('www.googleapis.com')
        response = do_http_get('/analytics/v3/management/segments?max-results=10000&fields=items(id,name,definition,updated)')
        json = decompress_gzip(response)
        @user_segments = json['items'].collect { |s| Segment.new(s) }
      end
      return @user_segments
    end

    # Returns the list of metadata available to the authenticated user.
    #
    # == Usage
    #   ga = Gattica.new({token: 'oauth2_token'})
    #   ga.metadata                       # Look up meta data
    #
    def metadata
      if @meta_data.nil?
        create_http_connection('www.googleapis.com')
        response = do_http_get('/analytics/v3/metadata/ga/columns')
        json = decompress_gzip(response)
        @meta_data = json['items'].collect { |md| MetaData.new(md) }
      end
      return @meta_data
    end

    # Returns the list of experiments available to the authenticated user for
    # a specific profile.
    #
    # == Usage
    #   ga = Gattica.new({token: 'oauth2_token'})
    #   ga.experiments(123456, 'UA-123456', 123456)         # Look up meta data
    #
    def experiments(account_id, web_property_id, profile_id)

      raise GatticaError::MissingAccountId, 'account_id is required' if account_id.nil? || account_id.empty?
      raise GatticaError::MissingWebPropertyId, 'web_property_id is required' if web_property_id.nil? || web_property_id.empty?
      raise GatticaError::MissingProfileId, 'profile_id is required' if profile_id.nil? || profile_id.empty?

      if @experiments.nil?
        create_http_connection('www.googleapis.com')
        response = do_http_get("/analytics/v3/management/accounts/#{account_id}/webproperties/#{web_property_id}/profiles/#{profile_id}/experiments")
        json = decompress_gzip(response)
        @experiments = json['items'].collect { |experiment| Experiment.new(experiment) }
      end
      return @experiments
    end

    # Uploads data for a custom data source
    #
    # == Usage
    #   ga = Gattica.new({token: 'oauth2_token'})
    #   ga.upload_data(account_id, web_property_id, custom_data_source_id, file)    # Upload data
    #
    def upload_data(account_id, web_property_id, custom_data_source_id, file)
      raise GatticaError::MissingFile, 'file is required' if file.nil? || file.empty?
      raise GatticaError::MissingAccountId, 'account_id is required' if account_id.nil? || account_id.empty?
      raise GatticaError::MissingCustomDataSourceId, 'custom_data_source_id is required' if custom_data_source_id.nil? || custom_data_source_id.empty?
      raise GatticaError::MissingWebPropertyId, 'web_property_id is required' if web_property_id.nil? || web_property_id.empty?
    
      create_http_connection('www.googleapis.com')
      response = do_http_post("/upload/analytics/v3/management/accounts/#{account_id}/webproperties/#{web_property_id}/customDataSources/#{custom_data_source_id}/uploads", content)

      return response
    end

    # This is a convenience method if you want just 1 data point.
    #
    # == Usage
    #
    #   ga = Gattica.new({token: 'oauth2_token'})
    #   ga.get_metric('2008-01-01', '2008-02-01', :pageviews)
    #
    # == Input
    #
    # When calling +get_metric+ you can pass in any options like you would to +get+
    #
    # Required arguments are:
    #
    # * +start_date+ => Beginning of the date range to search within
    # * +end_date+ => End of the date range to search within
    # * +metric+ => The metric you want to get the data point for
    #
    def get_metric(start_date, end_date, metric, options={})
     options.merge!( start_date: start_date.to_s,
                    end_date: end_date.to_s,
                    metrics:[metric.to_s] )
     get(options).try(:points).try(:[],0).try(:metrics).try(:[],0).try(:[],metric) || 0
    end

    # This is the method that performs the actual request to get data.
    #
    # == Usage
    #
    #   ga = Gattica.new({token: 'oauth2_token'})
    #   ga.get({ start_date: '2008-01-01',
    #            end_date: '2008-02-01',
    #            dimensions: 'browser',
    #            metrics: 'pageviews',
    #            sort: 'pageviews',
    #            filters: ['browser == Firefox']})
    #
    # == Input
    #
    # When calling +get+ you'll pass in a hash of options. For a description of what these mean to
    # Google Analytics, see http://code.google.com/apis/analytics/docs
    #
    # Required values are:
    #
    # * +start_date+ => Beginning of the date range to search within
    # * +end_date+ => End of the date range to search within
    #
    # Optional values are:
    #
    # * +dimensions+ => an array of GA dimensions (without the ga: prefix)
    # * +metrics+ => an array of GA metrics (without the ga: prefix)
    # * +filter+ => an array of GA dimensions/metrics you want to filter by (without the ga: prefix)
    # * +sort+ => an array of GA dimensions/metrics you want to sort by (without the ga: prefix)
    #
    # == Exceptions
    #
    # If a user doesn't have access to the +profile_id+ you specified, you'll receive an error.
    # Likewise, if you attempt to access a dimension or metric that doesn't exist, you'll get an
    # error back from Google Analytics telling you so.

    def get(args={})
      args = validate_and_clean(Settings::DEFAULT_ARGS.merge(args))
      query_string = build_query_string(args,@profile_id)
      @logger.debug(query_string) if @debug
      create_http_connection('www.googleapis.com')
      data = do_http_get("/analytics/v3/data/ga?samplingLevel=HIGHER_PRECISION&#{query_string}")
      json = decompress_gzip(data)
      return DataSet.new(json)
    end

    def mcf(args={})
      args = validate_and_clean(Settings::DEFAULT_ARGS.merge(args))
      query_string = build_query_string(args,@profile_id,true)
      @logger.debug(query_string) if @debug
      create_http_connection('www.googleapis.com')
      data = do_http_get("/analytics/v3/data/mcf?samplingLevel=HIGHER_PRECISION&#{query_string}")
      json = decompress_gzip(data)
      return DataSet.new(json)
    end

    # Since google wants the token to appear in any HTTP call's header, we have to set that header
    # again any time @token is changed so we override the default writer (note that you need to set
    # @token with self.token= instead of @token=)

    def token=(token)
      @token = token
      set_http_headers
    end

    ######################################################################
    private

    # Add the Google API key to the query string, if one is specified in the options.

    def add_api_key(query_string)
      query_string += "&key=#{@options[:api_key]}" if @options[:api_key]
      query_string
    end

    # Does the work of making HTTP calls and then going through a suite of tests on the response to make
    # sure it's valid and not an error

    def do_http_get(query_string)
      response = @http.get(add_api_key(query_string), @headers)

      # Response code error checking
      response_handling(response.code, response.body) if response.code != '200'

      return response.body
    end

    def do_http_post(query_string, body)
      response = @http.post(add_api_key(query_string), body, @headers)

      # Response code error checking
      response_handling(response.code, response.body) if response.code != '200'

      return response.body
    end


    # Response code error checking.
    def response_handling(code, body)
      case code
      when '400'
        raise GatticaError::AnalyticsError, body + " (status code: #{code})"
      when '401'
        raise GatticaError::InvalidToken, "Your authorization token is invalid or has expired (status code: #{code})"
      when '403'
        raise GatticaError::UserError, body + " (status code: #{code})"
      else
        raise GatticaError::UnknownAnalyticsError, body + " (status code: #{code})"
      end
    end


    # Sets up the HTTP headers that Google expects (this is called any time @token is set either by Gattica
    # or manually by the user since the header must include the token)
    # If the option for GZIP is set also send this within the headers
    def set_http_headers
      @headers['Authorization'] = "Bearer #{@token}"
      if @options[:gzip]
        @headers['Accept-Encoding'] = 'gzip'
        @headers['User-Agent'] = 'Net::HTTP (gzip)'
      end
    end


    # Decompress the JSON if GZIP is enabled
    def decompress_gzip(response)
      if @options[:gzip]
        sio       = StringIO.new(response)
        gz        = Zlib::GzipReader.new(sio)
        response  = gz.read()
      end
      json = JSON.parse(response)
      return json
    end


    # Creates a valid query string for GA
    def build_query_string(args,profile,mcf=false)
      output = "ids=ga:#{profile}&start-date=#{args[:start_date]}&end-date=#{args[:end_date]}"
      if (start_index = args[:start_index].to_i) > 0
        output += "&start-index=#{start_index}"
      end
      unless args[:dimensions].empty?
        output += '&dimensions=' + args[:dimensions].collect do |dimension|
          mcf ? "mcf:#{dimension}" : "ga:#{dimension}"
        end.join(',')
      end
      unless args[:metrics].empty?
        output += '&metrics=' + args[:metrics].collect do |metric|
          mcf ? "mcf:#{metric}" : "ga:#{metric}"
        end.join(',')
      end
      unless args[:sort].empty?
        output += '&sort=' + args[:sort].collect do |sort|
          sort[0..0] == '-' ? "-ga:#{sort[1..-1]}" : "ga:#{sort}"  # if the first character is a dash, move it before the ga:
        end.join(',')
      end
      unless args[:segment].nil?
        output += "&segment=#{args[:segment]}"
      end
      unless args[:max_results].nil?
        output += "&max-results=#{args[:max_results]}"
      end

      # TODO: update so that in regular expression filters (=~ and !~), any initial special characters in the regular expression aren't also picked up as part of the operator (doesn't cause a problem, but just feels dirty)
      unless args[:filters].empty?    # filters are a little more complicated because they can have all kinds of modifiers
        output += '&filters=' + args[:filters].collect do |filter|
          match, name, operator, expression = *filter.match(/^(\w*)\s*([=!<>~@]*)\s*(.*)$/)           # splat the resulting Match object to pull out the parts automatically
          unless name.empty? || operator.empty? || expression.empty?                      # make sure they all contain something
            "ga:#{name}#{CGI::escape(operator.gsub(/ /,''))}#{CGI::escape(expression.gsub(',', '\,'))}"   # remove any whitespace from the operator before output and escape commas in expression
          else
            raise GatticaError::InvalidFilter, "The filter '#{filter}' is invalid. Filters should look like 'browser == Firefox' or 'browser==Firefox'"
          end
        end.join(';')
      end
      return output
    end


    # Validates that the args passed to +get+ are valid
    def validate_and_clean(args)

      raise GatticaError::MissingStartDate, ':start_date is required' if args[:start_date].nil? || args[:start_date].empty?
      raise GatticaError::MissingEndDate, ':end_date is required' if args[:end_date].nil? || args[:end_date].empty?
      raise GatticaError::TooManyDimensions, 'You can only have a maximum of 7 dimensions' if args[:dimensions] && (args[:dimensions].is_a?(Array) && args[:dimensions].length > 7)
      raise GatticaError::TooManyMetrics, 'You can only have a maximum of 10 metrics' if args[:metrics] && (args[:metrics].is_a?(Array) && args[:metrics].length > 10)

      possible = args[:dimensions] + args[:metrics]

      # make sure that the user is only trying to sort fields that they've previously included with dimensions and metrics
      if args[:sort]
        missing = args[:sort].find_all do |arg|
          !possible.include? arg.gsub(/^-/,'')    # remove possible minuses from any sort params
        end
        unless missing.empty?
          raise GatticaError::InvalidSort, "You are trying to sort by fields that are not in the available dimensions or metrics: #{missing.join(', ')}"
        end
      end

      # make sure that the user is only trying to filter fields that are in dimensions or metrics
      if args[:filters]
        missing = args[:filters].find_all do |arg|
          !possible.include? arg.match(/^\w*/).to_s    # get the name of the filter and compare
        end
        unless missing.empty?
          raise GatticaError::InvalidSort, "You are trying to filter by fields that are not in the available dimensions or metrics: #{missing.join(', ')}"
        end
      end

      return args
    end

    def create_http_connection(server)
      port = Settings::USE_SSL ? Settings::SSL_PORT : Settings::NON_SSL_PORT
      @http =
      unless( @options[:proxy] )
        Net::HTTP.new(server, port)
      else
        Net::HTTP::Proxy( @options[:proxy][:host],  @options[:proxy][:port]).new(server, port)
      end
      @http.use_ssl = Settings::USE_SSL
      @http.verify_mode = @options[:verify_ssl] ? Settings::VERIFY_SSL_MODE : Settings::NO_VERIFY_SSL_MODE
      @http.set_debug_output $stdout if @options[:debug]
      @http.read_timeout = @options[:timeout] if @options[:timeout]
      if (@options[:ssl_ca_path] && File.directory?(@options[:ssl_ca_path]) && @http.use_ssl?)
        @http.ca_path = @options[:ssl_ca_path]
      end
    end

    def http_proxy
      proxy_host = @options[:http_proxy][:host]
      proxy_port = @options[:http_proxy][:port]
      proxy_user = @options[:http_proxy][:user]
      proxy_pass = @options[:http_proxy][:password]

      Net::HTTP::Proxy(proxy_host, proxy_port, proxy_user, proxy_pass)
    end

    # Sets instance variables from options given during initialization and
    def handle_init_options(options)
      @logger = options[:logger]
      @profile_id = options[:profile_id]
      @user_accounts = nil # filled in later if the user ever calls Gattica::Engine#accounts
      @user_segments = nil
      @headers = { }.merge(options[:headers]) # headers used for any HTTP requests (Google requires a special 'Authorization' header which is set any time @token is set)
      @default_account_feed = nil
    end

    # Use a token else, raise exception.
    def check_init_auth_requirements
      if @options[:token].to_s.length > 1
        self.token = @options[:token]
      else
        raise GatticaError::NoToken, 'An email and password or an authentication token is required to initialize Gattica.'
      end
    end

  end
end
