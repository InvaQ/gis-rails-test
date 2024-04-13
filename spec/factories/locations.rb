FactoryBot.define do
  factory :location do
    url { "https://example.com" }
    ip { "8.8.8.8" }
    latitude { 34.052363 }
    longitude { -118.256551 }
    location { {} }

  end
end