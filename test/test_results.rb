require File.expand_path('../helper', __FILE__)
require File.expand_path('../settings', __FILE__)

class TestResults < Test::Unit::TestCase

  def setup
    @response = GatticaTest::get({ start_index: 5, max_results: 5 })
  end

  def test_max_results
    assert @response.points.count == 5, 'should only return 5 results'
  end

  def test_start_index
    assert @response.points.first.title == 'ga:date=20100105', 'should start on the 5th'
  end

  def test_conversions
    assert @response.class.inspect == 'Gattica::DataSet', 'should be a Gattica:DataSet'
    assert @response.to_h.class.inspect == 'Hash', 'Should be a hash'
  end

end
