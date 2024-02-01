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

PLACES = {
  place_1: {
    place_name: 'FU Club Prague',
    capacity: 140,
    address: 'Praha 1',
    tags: [
      'PARTY',
      'MEETING',
      'POPUP',
      'BAR',
      'ART&CULTURE',
      'COMMUNITY',
      'OFFSITE',
      'BRAINSTORMING',
      'TEAMBUILDING',
      'INDOOR'
    ]
  },
  place_2: {
    place_name: 'The Original Beer Experience Prague',
    capacity: 350,
    address: 'Praha 1',
    tags: [
      'KONFERENCE',
      'MEETING',
      'PARTY',
      'POPUP',
      'INDOOR',
      'BAR',
      'HISTORICAL',
      'ART&CULTURE',
      'SVATBA',
      'COMMUNITY',
      'HOBBY',
      'WORKSHOP',
      'BRAINSTORMING',
      'TEAMBUILDING',
      'OFFSITE'
    ]
  },
  place_3: {
    place_name: 'Občanská plovárna',
    capacity: 2000,
    address: 'Praha 1 – Malá Strana',
    tags: [
      'PARTY',
      'ART&CULTURE',
      'KONFERENCE',
      'SVATBA',
      'KONGRES',
      'EXCLUSIVE',
      'STYLISH',
      'HISTORICAL',
      'TRADITIONAL',
      'WORKSHOP',
      'RESTAURANT',
      'INDOOR',
      'OUTDOOR',
      'BUSINESS'
    ]
  },
  place_4: {
    place_name: 'MOONCLUB',
    capacity: 500,
    address: 'Praha 1 - Staré Město',
    tags: [
      'PARTY',
      'BAR',
      'RESTAURANT',
      'POPUP',
      'STYLISH',
      'INDOOR',
      'ART&CULTURE',
      'MEETING',
      'INDUSTRIAL',
      'COMMUNITY',
      'OFFSITE'
    ]
  },
  place_5: {
    place_name: 'Cargo Gallery',
    capacity: 400,
    address: 'Praha 5 - Smíchov',
    tags: [
      'ALTERNATIVE',
      'INDOOR',
      'BAR',
      'STYLISH',
      'ART&CULTURE',
      'MEETING',
      'PARTY',
      'KONFERENCE',
      'POPUP',
      'OUTDOOR',
      'INDUSTRIAL',
      'COMMUNITY',
      'OFFSITE',
      'HOBBY',
      'PRODUCTION'
    ]
  },
  place_6: {
    place_name: 'Restaurace U Prince',
    capacity: 100,
    address: 'Praha 1 - Staré město',
    tags: %w[
      INDOOR
      MEETING
      DIPLOMATIC
      RESTAURANT
      HOTEL
      OUTDOOR
      STYLISH
      BAR
      TRADITIONAL
      HISTORICAL
      SVATBA
      BUSINESS
      TEAMBUILDING
      FAMILY
      EXCLUSIVE
    ]
  },
  place_7: {
    place_name: 'Terasa Smíchov',
    capacity: 400,
    address: 'Praha 5 - Smíchov',
    tags: [
      'PARTY',
      'MEETING',
      'KONFERENCE',
      'POPUP',
      'OUTDOOR',
      'BAR',
      'TRAINING',
      'YOGA',
      'COMMUNITY',
      'ART&CULTURE'
    ]
  }
}.freeze

VNITROBLOCK = {
  place_name: 'VNITROBLOCK',
  address: 'Praha 7 - Holešovice',
  tags: [
    'ALTERNATIVE',
    'MEETING',
    'INDOOR',
    'INDUSTRIAL',
    'ART&CULTURE',
    'POPUP',
    'STYLISH',
    'BAR',
    'COMMUNITY',
    'WORKSHOP',
    'PARTY'
  ],
  number_of_venues: {
    venue_1: {
      name: 'Hlavní prostor',
      capacity: 350
    },
    venue_2: {
      name: 'Kavárna',
      capacity: 50
    },
    venue_3: {
      name: 'Restaurace',
      capacity: 50
    },
    venue_4: {
      name: 'Terárko',
      capacity: 70
    },
    venue_5: {
      name: 'Pop-up store',
      capacity: 40
    },
    venue_6: {
      name: 'Glo Lounge',
      capacity: 30
    },
    venue_7: {
      name: 'Sector',
      capacity: 70
    }
  }
}.freeze

PLACES.each do |key, _value|
  # p place_name: PLACES[key][:place_name]
  # p address: PLACES[key][:address]
  # p tags: PLACES[key][:tags]
  place = Place.new(
    place_name: PLACES[key][:place_name],
    address: PLACES[key][:address],
    tags: PLACES[key][:tags],
    user: User.first
  )

  Venue.create(
    venue_name: PLACES[key][:place_name],
    description: 'Terasa Glo Lounge je součástí hlavního prostoru a samostatně se hodí na komorní akce nebo volnější schůzky a meetingy. Do místnosti lze zajistit občerstvení, PA, promítačku a plátno. Pojme do cca 30 lidí, podle náročnosti akce. Ideální pro workshopy, tiskové konference, eventy, Pop upy, přednášky, prezentace, oslavy, meetingy, atd',
    capacity: PLACES[key][:capacity],
    place: place
  )
  place.save
end

puts 'Done ✅'
