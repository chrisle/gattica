module Gattica
  module Settings

    USE_SSL = true
    SSL_PORT = 443
    NON_SSL_PORT = 80
    NO_VERIFY_SSL_MODE = OpenSSL::SSL::VERIFY_NONE
    VERIFY_SSL_MODE = OpenSSL::SSL::VERIFY_PEER

    TIMEOUT = 100

    DEFAULT_ARGS = {
        :start_date => nil,
        :end_date => nil,
        :dimensions => [],
        :metrics => [],
        :filters => [],
        :sort => []
    }

    DEFAULT_OPTIONS = {
        :email => nil,        # eg: 'email@gmail.com'
        :password => nil,     # eg: '$up3r_$ekret'
        :token => nil,
        :api_key => nil,
        :profile_id => nil,
        :debug => false,
        :headers => {},
        :logger => Logger.new(STDOUT),
        :verify_ssl => true
    }

    FILTER_METRIC_OPERATORS = %w{ == != > < >= <= }
    FILTER_DIMENSION_OPERATORS = %w{ == != =~ !~ =@ ~@ }
    

  end
end
