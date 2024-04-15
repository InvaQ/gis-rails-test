# GeoLocation API

The GeoLocation API allows you to manage and retrieve location data based on IP addresses and URLs. The API is built using Rails and follows the RESTful design principles. It supports JWT authorization for securing the endpoints.


## Getting Started

To get started with the GeoLocation API, ensure you have Ruby and Rails installed. Then, clone the repository and install the dependencies:



Configuration
To properly start the GeoLocation API, you need to set up the IPSTACK_API_KEY in the .env file:

Create a .env file in the root directory of your project.
Add the following line to the file, replacing [YOUR_API_KEY] with your actual API key:

```bash
IPSTACK_API_KEY=[YOUR_API_KEY]
```
This API key is required for using the IPStack service for geolocation data.

Generate secret token
```bash
bundle exec rails secret
```
And add the following line to the .env file
```bash
DEVISE_JWT_KEY=[generated_key]
```

## Docker-compose way
```bash
./bin/docker-setup.sh
```
or

```bash
bundle install
rails db:create
rails db:migrate
```

Start the Rails server:
```bash
rails s
```
Routes
The GeoLocation API provides the following routes:
```bash
GET /api/v1/locations: Retrieves all locations with an optional limit parameter.
GET /api/v1/locations/:id: Retrieves a location by its ID, IP, or URL.
POST /api/v1/locations: Creates a new location.
PATCH /api/v1/locations/:id: Updates an existing location.
DELETE /api/v1/locations/:id: Deletes a location.
All routes require JWT authorization, provided as a bearer token in the request headers.
```
Controller
The Api::V1::LocationsController handles the requests for the locations resources. It includes the following actions:

index: Retrieves a list of locations with an optional limit.
show: Retrieves a location based on its ID, IP, or URL.
create: Creates a new location.
update: Updates an existing location.
destroy: Deletes an existing location.
The controller uses a before_action filter to set the location object based on the request parameters.

Specs
The specs for the Api::V1::LocationsController are written using RSpec and cover the following actions:
```bash
GET #index: Tests for successful retrieval of locations and verifies the response size.
GET #show: Tests for successful retrieval of a location and not found status when the location does not exist.
POST #create: Tests for the creation of a new location and handling invalid parameters.
PATCH/PUT #update: Tests for updating a location and handling invalid parameters.
DELETE #destroy: Tests for successful deletion of a location and handling unsuccessful deletion attempts.
```

You can serve the API documentation using rswag:
```bash
rails rswag:specs:swaggerize
```