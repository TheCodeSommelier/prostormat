# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts 'Cleaning DB...'

Place.destroy_all
Bokee.destroy_all

puts 'Creating places...'

20.times do
  place = Place.new(place_name: Faker::Company.name, address: Faker::Address.full_address, user: User.first)

  rand(1..3).times do
    Venue.create(
      venue_name: Faker::Company.name,
      description: 'This is a room inside of a place...',
      capacity: rand(20..100),
      place: place
    )
  end
  place.save
end

puts 'Done ✅'
