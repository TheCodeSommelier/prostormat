# frozen_string_literal: true

namespace :places do
  desc 'Geocode places without coordinates'
  task geocode_missing: :environment do
    places_to_geocode = Place.where(latitude: nil).or(Place.where(longitude: nil))

    puts "Found #{places_to_geocode.count} places to geocode."

    places_to_geocode.find_each do |place|
      begin
        if place.geocode
          place.save
          puts "Successfully geocoded Place ID: #{place.id}, Address: #{place.full_address}"
        else
          puts "Failed to geocode Place ID: #{place.id}, Address: #{place.full_address}"
        end
      rescue StandardError => e
        puts "Error geocoding Place ID: #{place.id}, Address: #{place.full_address}. Error: #{e.message}"
      end

      sleep 1
    end

    puts 'Geocoding task completed.'
  end
end

namespace :orders do
  desc 'Check for unseen orders'
  task remind_owners: :environment do
    Order.where(unseen: true, notified: false)
         .where('delivered_at <= ?', Time.current - 3.days)
         .in_batches(of: 500) do |batch|
      batch.ids.each do |order_id|
        SendReminderToOwnerJob.perform_later(Order.find(order_id).place.id, order_id)
      end
    end
  end
end
