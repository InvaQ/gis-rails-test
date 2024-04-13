class LocationService
  attr_reader :base_url, :uri

  class << self
    def find_location_by_url(url)
      service = new(url)
      return nil unless service.valid_base_url?

      service.find_by_url
    end

    def find_or_create_location_by_url(url)
      service = new(url)
      return nil unless service.valid_base_url?

      service.find_or_create_location_by_url
    end

    def create_location_by(ip, url)
      service = new(url)
      if ip.blank?
        service.find_or_create_location_by_url if service.valid_base_url?
      else
        Location.create(ip:, url: service.base_url)
      end
    end
  end

  def initialize(url)
    @uri = parse_url(url)
    @base_url = valid_url? ? URI.join(uri.to_s, '/').to_s : nil
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

  def valid_base_url?
    base_url.present?
  end

  private

  def parse_url(url)
    URI.parse(url)
  rescue URI::InvalidURIError
    Rails.logger.error "Invalid URL provided: #{url}"
    nil
  end

  def valid_url?
    uri && (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.hostname
  rescue URI::InvalidURIError, URI::BadURIError
    Rails.logger.error "URL validation error"
    false
  end

  def fetch_ip_address
    ip_address = nil
    addr_info = Socket.getaddrinfo(uri.hostname, 'http', nil)
    ip_address = addr_info.dig(0, 3) if addr_info.any?
    ip_address
  rescue SocketError => e
    Rails.logger.error "Failed to resolve IP address for #{uri.hostname}: #{e.message}"
    nil
  end
end
