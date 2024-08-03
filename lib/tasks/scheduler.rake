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
    p "🔥 Orders are processed!"
  end
end

namespace :free_trial do
  desc 'Start free trial and send an email'
  task start: :environment do
    admin = User.find_by(admin: true)
    time_interval = Rails.env.production? ? 1.day.ago : 1.minute.ago
    p "🔥 time_interval #{time_interval}"

    places_to_update = Place.joins(:orders)
                            .where(user_id: admin.id, free_trial_start: nil)
                            .where('orders.delivered_at < ?', time_interval)
                            .group('places.id, places.owner_email')
                            .order('MAX(orders.delivered_at) DESC')

    ActiveRecord::Base.transaction do
      places_to_update.each do |place|
        place.update(free_trial_start: Time.current)
        SendFreeTrialEmailJob.perform_later(place.owner_email, place.id)
      end
    end
  end

  desc 'End free trial and hide places that have free trial over'
  task end: :environment do
    time_interval = Rails.env.production? ? 2.months.ago : 1.minute.ago
    p "🔥 time_interval #{time_interval}"
    places_free_trial_over = Place.where('free_trial_start < ? AND hidden = ?', time_interval, false)
    p "🔥 places_free_trial_over #{places_free_trial_over.length}"

    places_free_trial_over.find_each do |place|
      p "🔥 place_id #{place.id} --- place_owner_email #{place.owner_email} --- place_name #{place.place_name}"
      place.update(hidden: true)
      NotifyOwnerPlaceHiddenJob.perform_later(place.owner_email, place.id)
    end
  end
end
