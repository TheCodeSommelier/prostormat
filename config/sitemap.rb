# frozen_string_literal: true

# Set the host name for URL creation
host = Rails.env.production? ? 'https://www.prostormat.cz' : 'http://localhost:3000'
SitemapGenerator::Sitemap.default_host = host

SitemapGenerator::Sitemap.create do
  add root_path, priority: 1.0, changefreq: 'daily'
  add about_us_path, priority: 1.0, changefreq: 'daily'
  add faq_contact_path, priority: 1.0, changefreq: 'daily'
  add new_bulk_order_path, priority: 1.0, changefreq: 'daily'

  # /places (index)
  add places_path, priority: 0.7, changefreq: 'daily'

  # /place/:slug (show)
  Place.find_each do |place|
    add place_path(place.slug), lastmod: place.updated_at
  end
end
