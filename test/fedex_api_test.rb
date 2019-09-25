require 'minitest/autorun'
require 'dotenv/load'
require 'fedex_api'

class FedexApiTest < Minitest::Test
  def setup
    @shipper = {
      account_number: ENV['FEDEX_ACCOUNT_NUMBER'],
      contact: {
        company_name: 'test',
        phone_number: '12345678'
      },
      address: {
           street_lines: [ 'address 1', 'address 2' ],
           city: 'Prague',
           postal_code: '13000',
           country_code: 'CZ'
      }
    }
    @recipient = {
      contact: {
        company_name: 'test2',
        phone_number: '87654321'
      },
      address: {
           street_lines: 'address',
           city: 'Brussels',
           postal_code: '1000',
           country_code: 'BE'
      }
    }
  end

  def test_configuration
    assert FedexApi.currency == 'EUR'
    FedexApi.currency = 'USD'
    assert FedexApi.currency == 'USD'
  end

  def test_request_units
    FedexApi.currency == 'USD'
    service = FedexApi::Service::Rate.new(currency: 'EUR')

    assert service.currency == 'EUR'
    assert service.weight_unit == 'KG'
  end

  def test_pickup_service
    @shipper.delete(:account_number)
    now = DateTime.now

    # no weekends
    if now.wday == 5 || now.wday == 6
      now = DateTime.new(now.year, now.month, now.day + 8 - now.wday, now.hour, now.minute)
    end

    service = FedexApi::Service::Pickup.new
    service.pickup_location = @shipper
    service.ready_timestamp = DateTime.new(now.year, now.month, now.day + 1, 9)
    service.company_close_time = DateTime.new(now.year, now.month, now.day + 1, 18)
    service.packages << { weight: 1 }
    service.remarks = 'Thank you!'
    create_pickup_reply = service.create_pickup

    assert create_pickup_reply.success?

    service = FedexApi::Service::Pickup.new
    service.remarks = 'sorry :('

    cancel_pickup_reply = service.cancel_pickup(
      date: Date.new(now.year, now.month, now.day + 1),
      location: create_pickup_reply.body[:location],
      number: create_pickup_reply.body[:pickup_confirmation_number]
    )

    assert cancel_pickup_reply.success?
  end


  def test_rate_service
    service = FedexApi::Service::Rate.new
    service.shipper = @shipper
    service.recipient = @recipient
    service.packages << { weight: 1, length: 10, width: 10, height: 10 }
    reply = service.get_rates

    assert reply.success?
  end

  def test_ship_service
    service = FedexApi::Service::Ship.new
    service.shipper = @shipper
    service.recipient = @recipient
    service.delivery_instructions = 'foo'
    service.packages << { weight: 1, length: 10, width: 10, height: 10 }
    service.commodities << {
      description: 'commodity 1',
      country_of_manufacture: 'CZ',
      unit_price: 5,
      quantity: 4,
      customs_value: 20,
      weight: 0.5
    }
    service.commodities << {
      description: 'commodity 1',
      country_of_manufacture: 'CZ',
      unit_price: 10,
      quantity: 1,
      customs_value: 10,
      weight: 0.5
    }
    reply = service.process_shipment

    assert reply.success?
    assert reply.tracking_number
  end

  # Test Server Mock Tracking Numbers
  # https://www.fedex.com/us/developer/webhelp/ws/2019/US/wsdvg/Appendix_F_Test_Server_Mock_Tracking_Numbers.htm

  def test_track_service
    service = FedexApi::Service::Track.new
    reply = service.track('403934084723025', '122816215025810')

    assert reply.success?
    assert_equal 2, reply.tracking_details.size
    assert_equal 'Delivered', reply.tracking_details_for('122816215025810')[:status_detail][:description]
  end
end
