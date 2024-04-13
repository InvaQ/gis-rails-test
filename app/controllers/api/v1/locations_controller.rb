class Api::V1::LocationsController < Api::BaseController
  before_action :set_location, only: %i[update destroy]

  # GET /locations
  def index
    @locations = Location.limit(params[:limit])

    render json: @locations
  end

  # GET /locations/1
  def show
    @location =
      if params[:ip]
        Location.find_by(ip: params[:ip])
      elsif params[:url]
        LocationService.find_or_create_location_by_url(params[:url])
      else
        Location.find_by(id: params[:id])
      end

    @location ? (render json: @location) : (render json: { error: 'Location not found.' }, status: :not_found)
  end

  # POST /locations
  def create
    @location = LocationService.create_location_by(location_params[:ip], location_params[:url])

    if @location.persisted?
      render json: @location, status: :created
    else
      render json: @location&.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /locations/1
  def update
    if @location.update(location_params)
      render json: @location
    else
      render json: @location.errors, status: :unprocessable_entity
    end
  end

  # DELETE /locations/1
  def destroy
    if @location&.destroy
      render json: { message: 'Location deleted successfully.' }, status: :ok
    else
      render json: { error: 'Failed to delete location.' }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_location
    @location = Location.find_by(id: params[:id])
  end

  def location_params
    params.require(:location).permit(:ip, :url)
  end
end
