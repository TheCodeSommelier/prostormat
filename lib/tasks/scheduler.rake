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
        OrdersMailer.remind_owner(Order.find(order_id).place.id, order_id).deliver_later
      end
    end
    p '🔥 Orders are processed!'
  end
end

namespace :free_trial do
  desc 'Start free trial and send an email'
  task start: :environment do
    time_interval = Rails.env.production? ? 1.day.ago : 1.minute.ago
    p "🔥 time_interval #{time_interval}"

    places_to_update = Place.joins(:orders)
                            .where(user: User.where(admin: true), free_trial_end: nil)
                            .where('orders.created_at < ?', time_interval)
                            .group('places.id, places.owner_email')
                            .order('MAX(orders.created_at) DESC')

    p "🔥 places_to_update #{places_to_update.length}"
    ActiveRecord::Base.transaction do
      places_to_update.each do |place|
        place.update(free_trial_end: Time.current + 2.months)
        UserMailer.unregistered_user_trial_started(place.owner_email, place.id).deliver_later
      end
    end
  end

  desc 'Three days before free trial will end notification'
  task will_end: :environment do
    places_fr_tr_will_end = Place.where(
      free_trial_end: 3.days.ago..1.day.ago,
      hidden: false,
      user: User.where(admin: true)
    )
    places_fr_tr_will_end.each do |place|
      UserMailer.trial_ending_no_account(place.id, place.owner_email).deliver_later
    end
  end

  desc 'Hide places where free trial is over'
  task end: :environment do
    places_free_trial_over = Place.where(
      free_trial_end: ..Time.current,
      hidden: false,
      user: User.where(admin: true)
    )

    places_free_trial_over.find_each do |place|
      place.update(hidden: true)
      UserMailer.unregistered_user_trial_ended(place.id, place.owner_email).deliver_later
    end
  end
end
