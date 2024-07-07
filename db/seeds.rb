# frozen_string_literal: true

# # frozen_string_literal: true

# # This file should ensure the existence of records required to run the application in every environment (production,
# # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# #
# # Example:
# #
# #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
# #     MovieGenre.find_or_create_by!(name: genre_name)
# #   end

# puts 'Cleaning DB...'

# Place.destroy_all
# Bokee.destroy_all
Filter.destroy_all

# puts 'Creating places...'

# PLACES = {
#   place_1: {
#     place_name: 'FU Club Prague',
#     capacity: 140,
#     address: 'Praha 1',
#     city: 'Praha'

#   },
#   place_2: {
#     place_name: 'The Original Beer Experience Prague',
#     capacity: 350,
#     address: 'Praha 1',
#     city: 'Praha'

#   },
#   place_3: {
#     place_name: 'Občanská plovárna',
#     capacity: 2000,
#     address: 'Praha 1 – Malá Strana',
#     city: 'Praha'

#   },
#   place_4: {
#     place_name: 'MOONCLUB',
#     capacity: 500,
#     address: 'Praha 1 - Staré Město',
#     city: 'Praha'

#   },
#   place_5: {
#     place_name: 'Cargo Gallery',
#     capacity: 400,
#     address: 'Olomouc 5 - Smíchov',
#     city: 'Olomouc'

#   },
#   place_6: {
#     place_name: 'Restaurace U Prince',
#     capacity: 100,
#     address: 'Olomouc 1 - Staré město',
#     city: 'Olomouc'
#   },
#   place_7: {
#     place_name: 'Terasa Smíchov',
#     capacity: 400,
#     address: 'Olomouc 5 - Smíchov',
#     city: 'Olomouc'
#   }
# }.freeze

# VNITROBLOCK = {
#   place_name: 'VNITROBLOCK',
#   address: 'Ostrava 7 - Holešovice',
#   city: 'Ostrava',
#   number_of_venues: {
#     venue_1: {
#       name: 'Hlavní prostor',
#       capacity: 350
#     },
#     venue_2: {
#       name: 'Kavárna',
#       capacity: 50
#     },
#     venue_3: {
#       name: 'Restaurace',
#       capacity: 50
#     },
#     venue_4: {
#       name: 'Terárko',
#       capacity: 70
#     },
#     venue_5: {
#       name: 'Pop-up store',
#       capacity: 40
#     },
#     venue_6: {
#       name: 'Glo Lounge',
#       capacity: 30
#     },
#     venue_7: {
#       name: 'Sector',
#       capacity: 70
#     }
#   }
# }.freeze

# FILTER_NAMES = [
#   [
#     'alternative', 'meeting', 'indoor', 'industrial', 'art&culture', 'popup', 'stylish', 'bar', 'community', 'workshop',
#     'party', 'diplomatic', 'restaurant', 'hotel', 'outdoor', 'traditional', 'historical', 'svatba', 'business',
#     'teambuilding', 'family', 'exclusive', 'konference', 'training', 'yoga', 'offsite', 'hobby', 'production',
#     'brainstorming', 'kongres'
#   ]
# ].freeze

FILTER_NAMES = [
  %w[
    bar restaurant hotel indoor outdoor wedding industrial
  ]
].freeze

FILTER_NAMES[0].each do |filter|
  Filter.create(name: filter)
end

# PLACES.each do |_key, value|
#   place = Place.new(
#     place_name: value[:place_name],
#     address: value[:address],
#     city: value[:city],
#     user: User.first
#   )

#   Venue.create(
#     venue_name: value[:place_name],
#     description: 'Terasa Glo Lounge je součástí hlavního prostoru a samostatně se hodí na komorní akce nebo volnější schůzky a meetingy. Do místnosti lze zajistit občerstvení, PA, promítačku a plátno. Pojme do cca 30 lidí, podle náročnosti akce. Ideální pro workshopy, tiskové konference, eventy, Pop upy, přednášky, prezentace, oslavy, meetingy, atd',
#     capacity: value[:capacity],
#     place:
#   )
#   place.save
# end

# vnitroblock = Place.new(
#   place_name: VNITROBLOCK[:place_name],
#   address: VNITROBLOCK[:address],
#   city: VNITROBLOCK[:city],
#   user: User.first
# )

# VNITROBLOCK[:number_of_venues].each do |_key, value|
#   Venue.create(
#     venue_name: value[:name],
#     description: 'Terasa Glo Lounge je součástí hlavního prostoru a samostatně se hodí na komorní akce nebo volnější schůzky a meetingy. Do místnosti lze zajistit občerstvení, PA, promítačku a plátno. Pojme do cca 30 lidí, podle náročnosti akce. Ideální pro workshopy, tiskové konference, eventy, Pop upy, přednášky, prezentace, oslavy, meetingy, atd',
#     capacity: value[:capacity],
#     place: vnitroblock
#   )
# end

# vnitroblock.save

# puts 'Give places filters...'

# places = Place.all

# filters = Filter.all

# places.length.times do
#   rand(2..6).times do
#     PlaceFilter.create(place: places.sample, filter: filters.sample)
#   end
# end

# puts 'Done ✅'
