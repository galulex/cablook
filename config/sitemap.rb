require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://cablook.taxi'
SitemapGenerator::Sitemap.create do
  add '/home', changefreq:'monthly', priority: 0.9
  add '/contact_us', changefreq:'monthly'
  add '/about', changefreq: 'monthly'
  add '/why', changefreq: 'monthly'
  add '/faq', changefreq: 'monthly'
  add '/benefits', changefreq: 'monthly'
end
SitemapGenerator::Sitemap.ping_search_engines
