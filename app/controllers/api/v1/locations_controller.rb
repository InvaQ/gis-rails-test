class Api::V1::LocationsController < Api::BaseController
  before_action :set_location, only: %i[ show update destroy ]

  # GET /locations
  def index
    @locations = Location.limit(params[:limit])

    render json: @locations
  end

  # GET /locations/1
  def show
    @location ? (render json: @location) : (render json: { error: 'Location not found.' }, status: :not_found)
  end

  # POST /locations
  def create
    @location = Location.new(location_params)
    if @location.save
      render json: @location, status: :created
    else
      render json: @location.errors, status: :unprocessable_entity
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
    if @location && @location.destroy
      render json: { message: 'Location deleted successfully.' }, status: :ok
    else
      render json: { error: 'Failed to delete location.' }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_location
    @location = 
      if params[:ip]
        Location.find_by(ip: params[:ip])
      elsif params[:id]
        Location.find_by(id: params[:id])
      elsif params[:url]
        params[:action] == 'show' ? LocationService.find_or_create_location_by_url(params[:url]) : LocationService.find_location_by_url(params[:url])
      else
        nil
      end
  end

  def location_params
    params.require(:location).permit(:ip, :url)
  end
end
