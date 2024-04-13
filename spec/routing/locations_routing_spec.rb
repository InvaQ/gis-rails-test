require "rails_helper"

RSpec.describe Api::V1::LocationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/v1/locations").to route_to("api/v1/locations#index", format: :json)
    end

    it "routes to #show with ID" do
      expect(get: "/api/v1/locations/1").to route_to("api/v1/locations#show", id: "1", format: :json)
    end

    it "routes to #show with IP" do
      expect(get: "/api/v1/locations/?ip=1.2.3.4").to route_to("api/v1/locations#show", ip: "1.2.3.4", format: :json)
    end

    it "routes to #show with URL" do
      expect(get: "/api/v1/locations/?url=http://qwerty.com").to route_to("api/v1/locations#show", url: "http://qwerty.com", format: :json)
    end

    it "routes to #create" do
      expect(post: "/api/v1/locations").to route_to("api/v1/locations#create", format: :json)
    end

    it "routes to #update via PUT" do
      expect(put: "/api/v1/locations/1").to route_to("api/v1/locations#update", id: "1", format: :json)
    end

    it "routes to #update via PATCH" do
      expect(patch: "/api/v1/locations/1").to route_to("api/v1/locations#update", id: "1", format: :json)
    end

    it "routes to #destroy" do
      expect(delete: "/api/v1/locations/1").to route_to("api/v1/locations#destroy", id: "1", format: :json)
    end
  end
end
