require File.expand_path('../helper', __FILE__)
require File.expand_path('../settings', __FILE__)

class TestEngine < Test::Unit::TestCase

  def test_login_with_good_password
    assert Gattica.new(GatticaTest::DEFAULT_AUTH),
      'should have been able to login'
  end

  def test_login_with_bad_user_password
    assert_raise GatticaError::CouldNotAuthenticate do
      Gattica.new({ email: 'bad-email@gmail.com',
                    password: 'bad-password' })
    end
  end

  def test_accounts
    ga = Gattica.new(GatticaTest::DEFAULT_AUTH)
    accounts = ga.accounts
    assert accounts.count > 900, 'should have gotten at least 900 accounts'
  end

#  def test_timeout_too_short
#    ga = Gattica.new(GatticaTest::DEFAULT_AUTH.merge!(timeout: 0))
#    assert_raise Timeout::Error do
#      ga.accounts
#    end
#  end

  def test_setting_timeout
    ga = Gattica.new((GatticaTest::DEFAULT_AUTH).merge!(timeout: 300))
    http = ga.instance_variable_get('@http')
    assert http.read_timeout == 300, 'http timeout should be 300'
  end

#  def test_raise_error_when_no_user_pass_or_token_specified
#    assert_raise GatticaError::NoLoginOrToken do
#      Gattica.new
#    end
#  end
#
#  def test_use_an_existing_token
#    token = Gattica.new(@auth).token
#    assert Gattica.new({ token: token })
#  end

end
