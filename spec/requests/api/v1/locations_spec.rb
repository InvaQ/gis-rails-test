require 'swagger_helper'

require 'rails_helper'

RSpec.describe Api::V1::LocationsController, type: :controller do
  include ApiHelper

  let(:valid_attributes) do
    { ip: '8.8.8.8', url: 'https://example.com' }
  end

  let(:invalid_attributes) do
    { ip: 'invalid_ip', url: '' }
  end

  let(:location) do
    location = build(:location, valid_attributes)
    location.save(validate: false)
    location
  end

  before do
    user = create(:user)
    authenticated_header(request, user)
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
    allow(LocationService).to receive(:find_or_create_location_by_url).and_return(location)
    allow(LocationService).to receive(:find_location_by_url).and_return(location)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { limit: 10 }
      expect(response).to be_successful
    end

    it "returns an array of locations" do
      location
      get :index, params: { limit: 10 }
      expect(response.parsed_body.size).to eq(1)
    end
  end

  describe "GET #show" do
    it "returns a success response when a location is found" do
      get :show, params: { url: 'https://example.com' }
      expect(response).to be_successful
    end

    it "returns not found status when location is not found" do
      allow(LocationService).to receive(:find_or_create_location_by_url).and_return(nil)
      get :show, params: { url: 'https://nonexistent.com' }
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Location not found.")
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "does not create a new location because ip already taken" do
        expect do
          post :create, params: { location: valid_attributes }
        end.to change(Location, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "creates a new location" do
        Geocoder::Lookup::Test.add_stub(
          "9.9.9.9", [{
                                  "ip" => '9.9.9.9',
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
        expect do
          post :create, params: { location: { ip: '9.9.9.9', url: 'https://example1.com' } }
        end.to change(Location, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new location" do
        post :create, params: { location: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "with valid parameters" do
      it "updates the location" do
        Geocoder::Lookup::Test.add_stub(
          "111.22.33.44", [{
                                  "ip" => '8.8.8.8',
                                  "hostname" => 'blablabla.com',
                                  "latitude" => 35.052363,
                                  "longitude" => -52.256551,
                                  "address" => 'Las Vegas, NV, USA',
                                  "state" => 'Nevada',
                                  "state_code" => 'CA',
                                  "country_name" => 'United States',
                                  "zip" => 'AV3 Q3R',
                                  "country_code" => 'US',
                                  "location" => {},
                                  "data" => {}
                              }]
        )
        patch :update, params: { id: location.id, location: { ip: '111.22.33.44' } }
        location.reload
        expect(location.ip).to eq('111.22.33.44')
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid parameters" do
      it "does not update the location" do
        patch :update, params: { id: location.id, location: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested location" do
      delete :destroy, params: { id: location.id }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["message"]).to eq("Location deleted successfully.")
    end

    it "returns unprocessable entity status when location deletion fails" do
      delete :destroy, params: { id: location.id + 1 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
