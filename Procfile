web: env RUBY_DEBUG_OPEN=true bin/rails server

web: jemalloc.sh bundle exec puma -C config/puma.rb
worker: jemalloc.sh bundle exec sidekiq -C config/sidekiq.yml
