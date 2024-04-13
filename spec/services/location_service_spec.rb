require 'rails_helper'

RSpec.describe LocationService, type: :service do
  let(:valid_url) { "https://example.com" }
  let(:invalid_url) { "http_not_a_valid_url" }
  let(:db_sanitized_url) { "https://example.com/" }
  let(:ip_address) { "8.8.8.8" }

  before do
    Geocoder.configure(lookup: :test, ip_lookup: :test)
    Geocoder::Lookup::Test.add_stub(
      "8.8.8.8", [{
                                "ip" => '8.8.8.8',
                                "hostname" => 'blablabla.com',
                                "latitude" => 34.052363,
                                "longitude" => -118.256551,
                                "address" => 'Los Angeles, CA, USA',
                                "state" => 'California',
                                "state_code" => 'CA',
                                "country_name" => 'United States',
                                "zip" => 'AV3 Q3R',
                                "country_code" => 'US',
                                "location" => {},
                                "data" => {}
                            }]
    )
    allow(Socket).to receive(:getaddrinfo).and_return([['', '', '', ip_address]])
  end

  describe '.find_location_by_url' do
    context 'with a valid URL' do
      it 'returns the location if it exists' do
        location = build(:location, url: db_sanitized_url)
        location.save(validate: false)
        expect(LocationService.find_location_by_url(valid_url)).to eq(location)
      end

      it 'returns nil if the location does not exist' do
        expect(LocationService.find_location_by_url(valid_url)).to be_nil
      end
    end

    context 'with an invalid URL' do
      it 'returns nil' do
        expect(LocationService.find_location_by_url(invalid_url)).to be_nil
      end
    end
  end

  describe '.find_or_create_location_by_url' do
    context 'with a valid URL' do
      it 'returns the location if it exists' do
        location = build(:location, url: db_sanitized_url)
        location.save(validate: false)
        expect(LocationService.find_or_create_location_by_url(valid_url)).to eq(location)
      end

      it 'creates and returns a location if it does not exist' do
        expect { LocationService.find_or_create_location_by_url(valid_url) }.to change(Location, :count).by(1)
        location = Location.find_by(url: db_sanitized_url)
        expect(location.url).to eq(db_sanitized_url)
      end
    end

    context 'with an invalid URL' do
      it 'returns nil' do
        expect(LocationService.find_or_create_location_by_url(invalid_url)).to be_nil
      end
    end
  end

  describe '.create_location_by' do
    context 'with a valid IP address and URL' do
      it 'creates a location with the given IP and URL' do
        expect { LocationService.create_location_by(ip_address, valid_url) }.to change(Location, :count).by(1)
        location = Location.find_by(url: db_sanitized_url)
        expect(location.ip).to eq(ip_address)
      end
    end

    context 'with a blank IP address' do
      it 'finds or creates a location based on the URL' do
        expect { LocationService.create_location_by(nil, valid_url) }.to change(Location, :count).by(1)
        location = Location.find_by(url: db_sanitized_url)
        expect(location.url).to eq(db_sanitized_url)
      end
    end

    context 'with an invalid URL' do
      it 'does not create a location' do
        expect { LocationService.create_location_by(nil, invalid_url) }.not_to change(Location, :count)
      end
    end
  end

  describe '#find_or_create_location_by_url' do
    let(:service) { described_class.new(valid_url) }

    context 'when the location exists' do
      it 'returns the existing location' do
        location = build(:location, url: db_sanitized_url)
        location.save(validate: false)
        expect(service.find_or_create_location_by_url).to eq(location)
      end
    end

    context 'when the location does not exist' do
      it 'creates and returns a new location' do
        expect { service.find_or_create_location_by_url }.to change(Location, :count).by(1)
        location = Location.find_by(url: db_sanitized_url)
        expect(location.url).to eq(db_sanitized_url)
      end

      context 'when IP address cannot be fetched' do
        before do
          allow(service).to receive(:fetch_ip_address).and_return(nil)
        end

        it 'returns nil' do
          expect(service.find_or_create_location_by_url).to be_nil
        end
      end
    end
  end

  describe '#fetch_ip_address' do
    let(:service) { described_class.new(valid_url) }

    it 'returns the IP address of the URL hostname' do
      allow(Socket).to receive(:getaddrinfo).and_return([['', '', '', ip_address]])
      expect(service.send(:fetch_ip_address)).to eq(ip_address)
    end

    it 'returns nil if there is a network error' do
      allow(Socket).to receive(:getaddrinfo).and_raise(SocketError)
      expect(service.send(:fetch_ip_address)).to be_nil
    end
  end

  describe '#valid_url?' do
    let(:valid_service) { described_class.new(valid_url) }
    let(:invalid_service) { described_class.new(invalid_url) }

    it 'returns true for a valid URL' do
      expect(valid_service.send(:valid_url?)).to be_truthy
    end

    it 'returns false for an invalid URL' do
      expect(invalid_service.send(:valid_url?)).to be_falsey
    end
  end
end

#   describe '#find_or_create_location_by_url' do
#     context 'with an existing location' do
#       let!(:location) do
#         location = build(:location, url: db_sanitized_url, ip: ip_address)
#         location.save(validate: false)
#         location
#       end

#       it 'returns the existing location' do
#         service = LocationService.new(valid_url)
#         expect(service.find_or_create_location_by_url).to eq(location)
#       end
#     end

#     context 'when no existing location is found' do
#       it 'creates and returns a new location' do
#         service = LocationService.new(valid_url)
#         expect { service.find_or_create_location_by_url }.to change { Location.count }.by(1)
#         location = service.find_or_create_location_by_url
#         expect(location.url).to eq(db_sanitized_url)
#         expect(location.ip).to eq(ip_address)
#       end
#     end
#   end
# end
