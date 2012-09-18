Gattica
=======
Gattica is an easy to use Gem for getting data from the Google Analytics API.  

Features
--------
* Supports: metrics, dimensions, sorting, filters, goals, and segments.
* Handles accounts with over 1000 profiles
* Returns data as: hash, json, CSV

[How to export Google Analytics data using Ruby](
http://www.seerinteractive.com/blog/google-analytics-data-export-api-with-rubygattica/2011/02/22/) (Links to my blog post on [Seer Interactive](http://www.seerinteractive.com))

<hr />

Quick Start
===========
Here are bare basics to get you up and running.

Installation
------------
Add Gattica to your Gemfile

    gem 'gattica', :git => 'git://github.com/chrisle/gattica.git'

Don't forget to bundle install:

    $ bundle install

Login, get a list of accounts, pick an account, and get data:

    # Include the gem
    require 'gattica'
    
    # Login
    ga = Gattica.new({ 
        :email => 'email@gmail.com', 
        :password => 'password'
    })

    # Get a list of accounts
    accounts = ga.accounts

    # Choose the first account
    ga.profile_id = accounts.first.profile_id

    # Get the data
    data = ga.get({ 
        :start_date   => '2011-01-01',
        :end_date     => '2011-04-01',
        :dimensions   => ['month', 'year'],
        :metrics      => ['visits', 'bounces'],
    })

    # Show the data
    puts data.inspect

<hr />

General Usage
=============

### Create your Gattica object

    ga = Gattica.new({ :email => 'email@gmail.com', :password => 'password' })
    puts ga.token   # => returns a big alpha-numeric string
    
### Query for accounts you have access to

    # Retrieve a list of accounts
    accounts = ga.accounts

    # Show information about accounts
    puts "---------------------------------"
    puts "Available profiles: " + accounts.count.to_s
    accounts.each do |account|
      puts "   --> " + account.title
      puts "   last updated: " + account.updated.inspect
      puts "   web property: " + account.web_property_id
      puts "     profile id: " + account.profile_id.inspect
      puts "          goals: " + account.goals.count.inspect
    end

### Set which profile Gattica needs to use

    # Tell Gattica to query profile ID 5555555
    ga.profile_id = 5555555 

### Get data from Google Analytics
    
The Get method will get data from Google Analytics and return Gattica::DataSet type.  

* Dates must be in 'YYYY-MM-DD' format.  
* Dimensions and metrics can be gotten from [Google Analytics Dimensions & Metrics Reference](http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDimensionsMetrics.html)
* You do not need to use "ga:" at the beginning of the strings.

Here's an example:

    # Get the number of visitors by month from Jan 1st to April 1st.
    data = ga.get({ 
        :start_date   => '2011-01-01',
        :end_date     => '2011-04-01',
        :dimensions   => ['month', 'year'],
        :metrics      => ['visitors']
    })

<hr />

Using Dimension & Metrics
=========================

Here are some additional examples that illustrate different things you can do with dimensions and metrics.


### Sorting

    # Sorting by number of visits in descending order (most visits at the top)
    data = ga.get({ 
        :start_date   => '2011-01-01',
        :end_date     => '2011-04-01',
        :dimensions   => ['month', 'year'],
        :metrics      => ['visits'],
        :sort         => ['-visits']
    })

### Limiting results

    # Limit the number of results to 25.
    data = ga.get({ 
        :start_date   => '2011-01-01',
        :end_date     => '2011-04-01',
        :dimensions   => ['month', 'year'],
        :metrics      => ['visits'],
        :max_results  => 25 
    })

### Results as a Hash

    my_hash = data.to_h['points']

    # => 
    #   [{
    #     "xml"         => "<entry gd:etag=\"W/&quot;....  </entry>", 
    #     "id"          => "http://www.google.com/analytics/feeds/data?...", 
    #     "updated"     => Thu, 31 Mar 2011 17:00:00 -0700, 
    #     "title"       => "ga:month=01 | ga:year=2011", 
    #     "dimensions"  => [{:month=>"01"}, {:year=>"2011"}], 
    #     "metrics"     => [{:visitors=>6}]
    #   },
    #   {
    #     "xml"         => ...
    #     "id"          => ...
    #     "updated"     => ...
    #     ...
    #   }]


### JSON formatted string

    # Return data as a json string. (Useful for NoSQL databases)
    my_json = data.to_h['points'].to_json

    # => 
    #   "[{
    #       \"xml\":\"<entry> .... </entry>\",
    #       \"id\":\"http://www.google.com/analytics/feeds/data? ...",
    #       \"updated\":\"2011-03-31T17:00:00-07:00\",
    #       \"title\":\"ga:month=01 | ga:year=2011\",
    #       \"dimensions\":[{\"month\":\"01\"},{\"year\":\"2011\"}],
    #       \"metrics\":[{\"visitors\":6}]
    #     },
    #     { 
    #       \"xml\":\"<entry> .... </entry>\",
    #       \"id\":\"http://www.google.com/analytics/feeds/data? ...",
    #       ...
    #   }]"
    
### CSV formatted string

    # Return the data in CSV format.  (Useful for using in Excel.)

    # Short CSV will only return your dimensions and metrics:
    short_csv = data.to_csv(:short)   
    
    # => "month,year,visitors\n\n01,2011, ...."

    # Long CSV will get you a few additional columns:
    long_csv = data.to_csv            
    
    # => "id,updated,title,month,year,visitors\n\nhttp:// ..."


### DIY formatting

    # You can work directly with the 'point' method to return data.
    data.points.each do |data_point|
      month = data_point.dimensions.detect { |dim| dim.key == :month }.value
      year = data_point.dimensions.detect { |dim| dim.key == :year }.value
      visitors = data_point.metrics.detect { |metric| metric.key == :visitors }.value
      puts "#{month}/#{year} got #{visitors} visitors"
    end

    # => 
    #   01/2011 got 34552 visitors
    #   02/2011 got 36732 visitors
    #   03/2011 got 45642 visitors
    #   04/2011 got 44456 visitors

<hr />

Using Filter, Goals, and Segments
=========================

Learn more about filters: [Google Data feed filtering reference](http://code.google.com/apis/analytics/docs/gdata/gdataReference.html#filtering)


### Get profiles with goals

    # Get all the profiles that have goals
    profiles_with_goals = accounts.select { |account| account.goals.count > 0 }

    # => 
    #   [{
    #     "id"                => "http://www.google.com/analytics/feeds/accounts/ga:...",
    #     "updated"           => Mon, 16 May 2011 16:40:30 -0700, 
    #     "title"             => "Profile Title", 
    #     "table_id"          => "ga:123456", 
    #     "account_id"        => 123456, 
    #     "account_name"      => "Account name", 
    #     "profile_id"        =>  123456, 
    #     "web_property_id"   => "UA-123456-3", 
    #     "goals"=>[{
    #         :active   => "true", 
    #         :name     => "Goal name", 
    #         :number   => 1, 
    #         :value    => 0.0
    #     }]
    #   }, 
    #   {
    #     "id"                => "http://www.google.com/analytics/feeds/accounts/ga:...",
    #     "updated"           => Mon, 16 May 2011 16:40:30 -0700, 
    #     "title"             => "Profile Title", 
    #     ...
    #   }]

### List available segments

    # Get all the segments that are available to you
    segments = ga.segments

    # Segments with negative gaid are default segments from Google. Segments
    # with positive gaid numbers are custom segments that you created.
    # =>
    #   [{
    #     "id"          => "gaid::-1", 
    #     "name"        => "All Visits", 
    #     "definition"  => " "
    #   }, 
    #   {
    #     "id"          => "gaid::-2", 
    #     "name"        => "New Visitors", 
    #     "definition"  => "ga:visitorType==New Visitor"
    #   }, 
    #   {
    #     "id"          => ... # more default segments
    #     "name"        => ...
    #     "definition"  => ...
    #   },
    #   {
    #     "id"          => "gaid::12345678", 
    #     "name"        => "Name of segment", 
    #     "definition"  => "ga:keyword=...."
    #   }, 
    #   {
    #     "id"          => ... # more custom segments
    #     "name"        => ...
    #     "definition"  => ...
    #   }]

### Query by segment

    # Return visits and bounces for mobile traffic 
    # (Google's default user segment gaid::-11)
    
    mobile_traffic = ga.get({ 
      :start_date   => '2011-01-01', 
      :end_date     => '2011-02-01', 
      :dimensions   => ['month', 'year'],
      :metrics      => ['visits', 'bounces'],
      :segment      => 'gaid::-11'
    })

### Filtering

Filters are boolean expressions in strings. Here's an example of an equality:

    # Filter by Firefox users
    firefox_users = ga.get({
      :start_date   => '2010-01-01', 
      :end_date     => '2011-01-01',
      :dimensions   => ['month', 'year'],
      :metrics      => ['visits', 'bounces'],
      :filters      => ['browser == Firefox']
    })
    
Here's an example of greater-than:
    
    # Filter where visits is >= 10000
    lots_of_visits = ga.get({
      :start_date   => '2010-01-01', 
      :end_date     => '2011-02-01',
      :dimensions   => ['month', 'year'],
      :metrics      => ['visits', 'bounces'],
      :filters      => ['visits >= 10000']
    })
    
Multiple filters is an array.  Currently, they are only joined by 'AND'.

    # Firefox users and visits >= 10000
    firefox_users_with_many_pageviews = ga.get({
      :start_date   => '2010-01-01', 
      :end_date     => '2011-02-01',
      :dimensions   => ['month', 'year'],
      :metrics      => ['visits', 'bounces'],
      :filters      => ['browser == Firefox', 'visits >= 10000']
    })


<hr />

Even More Examples!
===============

### Top 25 keywords that drove traffic

Output the top 25 keywords that drove traffic to your website in the first quarter of 2011.

    # Get the top 25 keywords that drove traffic
    data = ga.get({ 
      :start_date => '2011-01-01',
      :end_date => '2011-04-01',
      :dimensions => ['keyword'],
      :metrics => ['visits'],
      :sort => ['-visits'],
      :max_results => 25 
    })
    
    # Output our results
    data.points.each do |data_point|
      kw = data_point.dimensions.detect { |dim| dim.key == :keyword }.value
      visits = data_point.metrics.detect { |metric| metric.key == :visits }.value
      puts "#{visits} visits => '#{kw}'"
    end

    # =>
    #   19667 visits => '(not set)'
    #   1677 visits => 'keyword 1'
    #   178 visits => 'keyword 2'
    #   165 visits => 'keyword 3'
    #   161 visits => 'keyword 4'
    #   112 visits => 'keyword 5'
    #   105 visits => 'seo company reviews'
    #   ...
    
<hr />

Additional Options & Settings
=============================

Setting HTTP timeout
--------------------

If you have a lot of profiles in your account (like 1000+ profiles) querying for accounts may take over a minute.  Net::HTTP will timeout and an exception will be raised.

To avoid this, specify a timeout when you instantiate the Gattica object:

    ga = Gattica.new({ 
        :email => 'email@gmail.com', 
        :password => 'password',
        :timeout => 600  # Set timeout for 10 minutes!
    })

The default timeout is 300 seconds (5 minutes). Change the default in: lib/gattica/settings.rb

For reference 1000 profiles with 2-5 goals each takes around 90-120 seconds.

Reusing a session token
-----------------------

You can reuse an older session if you still have the token string.  Google recommends doing this to avoid authenticating over and over.

  
    my_token = ga.token # => 'DSasdf94...'
    
    # Sometime later, you can initialize Gattica with the same token
    ga = Gattica.new({ :token => my_token })

If your token times out, you will need to re-authenticate.

Specifying your own headers
---------------------------

Google expects a special header in all HTTP requests called 'Authorization'.  Gattica handles this header automatically.  If you want to specify your own you can do that when you instantiate Gattica:

    ga = Gattica.new({
        :token => 'DSasdf94...', 
        :headers => {'My-Special-Header':'my_custom_value'}
    })
        
<hr />

History
=======

Version history
---------------
### 0.6.1
  * Incorporated fixes by vgololobov
    * Removed circular dependency
    * Fixed 1.9.3 init exception https://github.com/chrisle/gattica/pull/6

### 0.6.0
  * Update to use Google Analytics v2.4 management API

    TL;DR: Uses the v2.4 API now because Google deprecated <2.3.
      
    * :) - Drop-in replacement for you.
    * :) - Won't timeout anymore.
    * :) - Accounts method might be faster if you have a few profiles
    * :( - Accounts method is notably slower if you have >1000 profiles.

    Google has changed the output of the API < 2.3.  Most notable changes
    were the output of what was the /management/accounts/default call.  Some 
    of the XML changed, but most notably it didn't return everything all at
    once.  It used to look like this: http://bit.ly/w6Ummj
    
  * Fixed token [deviantech]

### 0.5.1
  * Added some tests - needs more work :(

### 0.4.7
  * Removed version numbers [john mcgrath]

### 0.4.6
  * Removed monkey patch [mathieuravaux]

### 0.4.4
  * Added a configuration file to unit tests
  * Removed version.rb.  Not needed. (thanks John McGrath see: github.com/john)
  * Migrated examples and rewrote README file

### 0.4.3
  * FIXED: Typo in start-index parameter
  * Refactored Engine class into it's own file.
  * Began to re-style code to wrap at 80 characters
  * Added some unit tests

### 0.4.2
  * Added Ruby 1.9 support (Thanks @mathieuravaux https://github.com/mathieuravaux)
  * Uses hpricot 0.8.4 now.  0.8.3 segfaults.
  * Added ability to change the timeout when requesting analytics from Google
  * Added the ability to use max_results

### 0.3.2.scottp
  * scottp Added Analytics API v2 header, and basic support for "segment" argument.

### 0.3.2
  * er1c updated to use standard Ruby CSV library

### 0.3.0
  * Support for filters (filters are all AND'ed together, no OR yet)

### 0.2.1 
  * More robust error checking on HTTP calls
  * Added to_xml to get raw XML output from Google
  
### 0.2.0 / 2009-04-27
  * Changed initialization format: pass a hash of options rather than individual email, password and profile_id
  * Can initialize with a valid token and use that instead of requiring email/password each time
  * Can initialize with your own logger object instead of having to use the default (useful if you're using with Rails, initialize with RAILS_DEFAULT_LOGGER)
  * Show error if token is invalid or expired (Google returns a 401 on any HTTP call)
  * Started tests

### 0.1.4 / 2009-04-22
  * Another attempt at getting the gem to build on github

### 0.1.3 / 2009-04-22
  * Getting gem to build on github

### 0.1.2 / 2009-04-22
  * Updated readme and examples, better documentation throughout

### 0.1.1 / 2009-04-22
  * When outputting as CSV, surround each piece of data with double quotes (appears pretty common for various properties (like Browser name) to contain commas

### 0.1.0 / 2009-03-26
  * Basic functionality working good. Can't use filters yet.
  

Maintainer history
------------------
  * [Rob Cameron](https://github.com/activenetwork/gattica) (2010)
  * [Mike Rumble](https://github.com/rumble/gattica) (2010)
  * [Chris Le](https://github.com/chrisle/gattica) (Current)
  
