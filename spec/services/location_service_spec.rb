require 'rails_helper'

RSpec.describe LocationService, type: :service do
  let(:valid_url) { "https://example.com" }
  let(:invalid_url) { "http_not_a_valid_url" }
  let(:base_url) { "https://example.com/" }
  let(:ip_address) { "8.8.8.8" }

  before do
    uri = URI.parse(valid_url)
    http = double('Net::HTTP')
    request = double('Net::HTTP::Head')
    response = double('Net::HTTPResponse')

    Geocoder.configure(:lookup => :test, ip_lookup: :test)
    Geocoder::Lookup::Test.add_stub(
        "8.8.8.8", [{
                                "ip"    => '8.8.8.8',
                                "hostname"    => 'blablabla.com',
                                "latitude"    => 34.052363,
                                "longitude"    => -118.256551,
                                "address"      => 'Los Angeles, CA, USA',
                                "state"        => 'California',
                                "state_code"   => 'CA',
                                "country_name"      => 'United States',
                                "zip" => 'AV3 Q3R',
                                "country_code" => 'US',
                                "location" => {},
                                "data" => {},
                            }],

    )
    allow(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(http)
    allow(http).to receive(:use_ssl=).with(true)
    allow(Net::HTTP::Head).to receive(:new).with(uri).and_return(request)
    allow(http).to receive(:request).with(request).and_return(response)
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    allow(response).to receive(:remote_ip).and_return(ip_address)
  end

  describe '#find_or_create_location_by_url' do
    context 'with an existing location' do
      let!(:location) do
        location = build(:location, url: base_url, ip: ip_address)
        location.save(validate: false)
        location
      end

      it 'returns the existing location' do
        service = LocationService.new(valid_url)
        expect(service.find_or_create_location_by_url).to eq(location)
      end
    end

    context 'when no existing location is found' do
      it 'creates and returns a new location' do
        service = LocationService.new(valid_url)
        expect { service.find_or_create_location_by_url }.to change { Location.count }.by(1)
        location = service.find_or_create_location_by_url
        expect(location.url).to eq(base_url)
        expect(location.ip).to eq(ip_address)
      end
    end

    context 'when network error occurs' do
      before do
        allow(Net::HTTP).to receive(:new).and_raise(Net::OpenTimeout)
      end

      it 'returns nil' do
        service = LocationService.new(valid_url)
        expect(service.find_or_create_location_by_url).to be_nil
      end

      it 'returns nil if invalid url' do
        service = LocationService.new(invalid_url)
        expect(service.find_or_create_location_by_url).to be_nil
      end
    end
  end

end
