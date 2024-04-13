# == Schema Information
#
# Table name: locations
#
#  id             :bigint           not null, primary key
#  ip             :string
#  hostname       :string
#  type           :string
#  url            :string
#  latitude       :float            not null
#  longitude      :float            not null
#  city           :string
#  zip            :string
#  region_name    :string
#  region_code    :string
#  country_name   :string
#  country_code   :string
#  continent_code :string
#  continent_name :string
#  raw_data       :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Location < ApplicationRecord
  
  geocoded_by :ip do |obj, results|
    if (geo = results.first)
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      obj.hostname = geo&.hostname
      obj.ip_type = geo.data["type"]
      obj.city = geo.city
      obj.region_name = geo.state
      obj.region_code = geo.state_code
      obj.zip = geo.postal_code
      obj.country_name = geo.country
      obj.country_code = geo.country_code
      obj.location = geo.location
      obj.raw_data = geo.data
    else
      errors.add(:ip, 'is invalid or could not be geocoded')
    end
  end
  
  validates :ip, format: { :with => Resolv::AddressRegex }
  validates :ip, presence: true, uniqueness: true
  after_validation :geocode, if: ->(obj){ obj.ip_changed? && obj.errors.empty? }
end
