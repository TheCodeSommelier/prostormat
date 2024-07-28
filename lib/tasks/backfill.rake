# frozen_string_literal: true

namespace :backfill do
  desc 'Backfill slugs for places'
  task slugs: :environment do
    Place.where(slug: [nil, '']).find_each do |place|
      place.send(:generate_slug)
      if place.save
        puts "Generated and saved slug for: #{place.place_name}"
      else
        puts "Failed to save slug for: #{place.place_name} - #{place.errors.full_messages.join(', ')}"
      end
    end
  end

  desc 'Backfill secondary emails'
  task owner_email: :environment do
    puts 'Filling owner emails...'
    Place.includes(:user).where(owner_email: [nil, '']).find_each do |place|
      place.update(owner_email: place.user.email)
    end
    puts 'Finished!'
  end
end
