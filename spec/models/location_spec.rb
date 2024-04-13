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
require 'rails_helper'

RSpec.describe Location, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
