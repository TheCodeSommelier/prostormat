require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# TODO: Admin can edit all places
# TODO: Footer
# TODO: Test stripe in prod
# TODO: Admin can mark as primary
# TODO: Services
# TODO: About us page
# TODO: Contact page and FAQs
# TODO: Change price ID env variable to actual price ID
# TODO: Talk with martin potentially remove bokee model to keep the cost down

module SpaceMi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_storage.service = :cloudinary

    config.assets.enabled = true

    config.action_mailer.delivery_method = :postmark

    config.action_mailer.postmark_settings = {
      api_token: ENV.fetch('POSTMARK_API_TOKEN')
    }

    # Uses sidekiq for background job processing
    config.active_job.queue_adapter = :sidekiq
  end
end
