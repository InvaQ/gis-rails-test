class LocationService
  attr_reader :base_url, :uri

  class << self
    def find_location_by_url(url)
      service = new(url)
      return nil unless service.base_url

      service.find_by_url
    end

    def find_or_create_location_by_url(url)
      service = new(url)
      return nil unless service.base_url

      service.find_or_create_location_by_url
    end
  end

  def initialize(url)
    @uri = URI.parse(url)
    @base_url = valid_url? ? URI.join(url, "/").to_s : nil
  end

  def find_or_create_location_by_url
    location = find_by_url

    return location if location

    ip_address = fetch_ip_address
    return nil unless ip_address

    Location.find_or_create_by(ip: ip_address, url: base_url)
  end

  def find_by_url
    Location.find_by(url: base_url)
  end

  private

  def valid_url?
    (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.hostname
  rescue URI::InvalidURIError, URI::BadURIError
    Rails.logger.error "Invalid URL"
    false
  end

  def fetch_ip_address
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    request = Net::HTTP::Head.new(uri)
    response = http.request(request)

    response.remote_ip if response.is_a?(Net::HTTPSuccess)
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    Rails.logger.error "Network error while fetching IP address: #{e.message}"
    nil
  end
end
