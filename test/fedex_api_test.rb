require 'minitest/autorun'
require 'fedex_api'

class FedexApiTest < Minitest::Test
  def test_configuration
    assert FedexApi.currency == 'EUR'
    FedexApi.currency = 'USD'
    assert FedexApi.currency == 'USD'
  end
end
