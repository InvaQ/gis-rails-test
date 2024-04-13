class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :ip, index: { unique: true } # can be inet
      t.string :ip_type
      t.string :hostname
      t.string :url
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.string :city
      t.string :zip
      t.string :region_name
      t.string :region_code
      t.string :country_name
      t.string :country_code
      t.string :continent_code
      t.string :continent_name
      t.jsonb :location
      t.jsonb :raw_data

      t.timestamps
    end
    add_index :locations, %i[latitude longitude]
    add_index :locations, :url, unique: true, where: 'url IS NOT NULL'
  end
end
