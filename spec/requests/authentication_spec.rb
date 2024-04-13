require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  before do
    @params = { user: { email: 'test@example.com', password: 'password' } }.to_json
    @headers = { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
  end

  describe "POST /auth/signup" do
    it "creates a new user" do
      post '/auth/signup', params: @params, headers: @headers
      expect(response).to have_http_status(:created)
      expect(response).to include('authorization')
    end
  end

  context "user exists" do
    before do
      User.create(email: 'test@example.com', password: 'password')
    end

    describe "POST /auth/login" do
      it "authenticates the user and returns auth token" do
        post '/auth/login', params: @params, headers: @headers
        expect(response).to have_http_status(:ok)
        expect(response).to include('authorization')
      end
    end

    describe "DELETE /auth/logout" do
      it "logs out the user" do
        post '/auth/login', params: @params, headers: @headers
        auth_token = response.headers['authorization']

        delete '/auth/logout', headers: { 'Authorization' => auth_token }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
