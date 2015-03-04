module GatticaTest
  
  DEFAULT_AUTH = {
      email: 'name@email.com',
      password: 'password',
      debug: true
  }
  DEFAULT_QUERY = {
      start_date: '2010-01-01',
      end_date: '2011-01-01',
      dimensions: ['date'],
      metrics: ['visits']
  }
  PROFILE_ID = 23987717

  def self.ga(options={}, profile_id=PROFILE_ID)
    unless defined? @ga
      @ga = Gattica.new(DEFAULT_AUTH)
      @ga.profile_id = profile_id
    end
    @ga
  end

  def self.get(options={}, profile_id=PROFILE_ID)
    ga.get(DEFAULT_QUERY.merge(options))
  end
  
end
