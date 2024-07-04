# frozen_string_literal: true

url = Rails.env.production? ? ENV.fetch('STACKHERO_REDIS_URL_TLS') : ENV['REDISCLOUD_URL']

if url
  Sidekiq.configure_server do |config|
    config.redis = { url: }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: }
  end
end
