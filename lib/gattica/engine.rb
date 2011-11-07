module Gattica
  class Engine

    attr_reader :user
    attr_accessor :profile_id, :token

    # Initialize Gattica using username/password or token.
    #
    # == Options:
    # To change the defaults see link:settings.rb
    # +:debug+::        Send debug info to the logger (default is false)
    # +:email+::        Your email/login for Google Analytics
    # +:headers+::      Add additional HTTP headers (default is {} )
    # +:logger+::       Logger to use (default is STDOUT)
    # +:password+::     Your password for Google Analytics
    # +:profile_id+::   Use this Google Analytics profile_id (default is nil)
    # +:timeout+::      Set Net:HTTP timeout in seconds (default is 300)
    # +:token+::        Use an authentication token you received before
    def initialize(options={})
      @options = Settings::DEFAULT_OPTIONS.merge(options)
      handle_init_options(@options)
      create_http_connection()
      check_init_auth_requirements()
      # TODO: check that the user has access to the specified profile and show an error here rather than wait for Google to respond with a message
    end

    # Returns the list of accounts the user has access to. A user may have
    # multiple accounts on Google Analytics and each account may have multiple
    # profiles. You need the profile_id in order to get info from GA. If you
    # don't know the profile_id then use this method to get a list of all them.
    # Then set the profile_id of your instance and you can make regular calls
    # from then on.
    #
    #   ga = Gattica.new({:email => 'johndoe@google.com', :password => 'password'})
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
      # if we haven't retrieved the user's accounts yet, get them now and save them
      if @user_accounts.nil?
        data = request_default_account_feed
        xml = Hpricot(data)
        @user_accounts = xml.search(:entry).collect { |entry| Account.new(entry) }
      end
      return @user_accounts
    end

    # Returns the list of segments available to the authenticated user.
    #
    # == Usage
    #   ga = Gattica.new({:email => 'johndoe@google.com', :password => 'password'})
    #   ga.segments                       # Look up segment id
    #   my_gaid = 'gaid::-5'              # Non-paid Search Traffic
    #   ga.profile_id = 12345678          # Set our profile ID
    #
    #   gs.get({ :start_date => '2008-01-01',
    #            :end_date => '2008-02-01',
    #            :dimensions => 'month',
    #            :metrics => 'views',
    #            :segment => my_gaid })

    def segments
      if @user_segments.nil?
        data = request_default_account_feed
        xml = Hpricot(data)
        @user_segments = xml.search("dxp:segment").collect { |s| Segment.new(s) }
      end
      return @user_segments
    end

    # This is the method that performs the actual request to get data.
    #
    # == Usage
    #
    #   gs = Gattica.new({:email => 'johndoe@google.com', :password => 'password', :profile_id => 123456})
    #   gs.get({ :start_date => '2008-01-01',
    #            :end_date => '2008-02-01',
    #            :dimensions => 'browser',
    #            :metrics => 'pageviews',
    #            :sort => 'pageviews',
    #            :filters => ['browser == Firefox']})
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
      data = do_http_get("/analytics/feeds/data?#{query_string}")
      #data = do_http_get("/analytics/feeds/data?ids=ga%3A915568&metrics=ga%3Avisits&segment=gaid%3A%3A-7&start-date=2010-03-29&end-date=2010-03-29&max-results=50")
      return DataSet.new(Hpricot.XML(data))
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

    # Gets the default account feed from Google
    def request_default_account_feed
      if @default_account_feed.nil?
        @default_account_feed = do_http_get('/analytics/feeds/accounts/default')
      end
      return @default_account_feed
    end

    # Does the work of making HTTP calls and then going through a suite of tests on the response to make
    # sure it's valid and not an error

    def do_http_get(query_string)
      response, data = @http.get(query_string, @headers)

      # error checking
      if response.code != '200'
        case response.code
        when '400'
          raise GatticaError::AnalyticsError, response.body + " (status code: #{response.code})"
        when '401'
          raise GatticaError::InvalidToken, "Your authorization token is invalid or has expired (status code: #{response.code})"
        else  # some other unknown error
          raise GatticaError::UnknownAnalyticsError, response.body + " (status code: #{response.code})"
        end
      end

      return data
    end


    # Sets up the HTTP headers that Google expects (this is called any time @token is set either by Gattica
    # or manually by the user since the header must include the token)
    def set_http_headers
      @headers['Authorization'] = "GoogleLogin auth=#{@token}"
      @headers['GData-Version']= '2'
    end


    # Creates a valid query string for GA
    def build_query_string(args,profile)
      output = "ids=ga:#{profile}&start-date=#{args[:start_date]}&end-date=#{args[:end_date]}"
      if (start_index = args[:start_index].to_i) > 0
        output += "&start-index=#{start_index}"
      end
      unless args[:dimensions].empty?
        output += '&dimensions=' + args[:dimensions].collect do |dimension|
          "ga:#{dimension}"
        end.join(',')
      end
      unless args[:metrics].empty?
        output += '&metrics=' + args[:metrics].collect do |metric|
          "ga:#{metric}"
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
            "ga:#{name}#{CGI::escape(operator.gsub(/ /,''))}#{CGI::escape(expression)}"   # remove any whitespace from the operator before output
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

    def create_http_connection
      port = Settings::USE_SSL ? Settings::SSL_PORT : Settings::NON_SSL_PORT
      @http = Net::HTTP.new(Settings::SERVER, port)
      @http.use_ssl = Settings::USE_SSL
      @http.set_debug_output $stdout if @options[:debug]
      @http.read_timeout = @options[:timeout] if @options[:timeout]
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

    # If the authorization is a email and password then create User objects
    # or if it's a previous token, use that.  Else, raise exception.
    def check_init_auth_requirements
      if @options[:token].to_s.length > 200 # Not sure actual required length, but mine's 267
        self.token = @options[:token]
      elsif @options[:email] && @options[:password]
        @user = User.new(@options[:email], @options[:password])
        @auth = Auth.new(@http, user)
        self.token = @auth.tokens[:auth]
      else
        raise GatticaError::NoLoginOrToken, 'An email and password or an authentication token is required to initialize Gattica.'
      end
    end

  end
end
