web: env RUBY_DEBUG_OPEN=true bin/rails server

web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
