require "bundler/setup"
require "./lib/share"
require "sprockets"

map "/assets" do
  assets = Sprockets::Environment.new
  assets.append_path "assets/images"
  assets.append_path "assets/stylesheets"
  assets.append_path "assets/javascripts"
  run assets
end

run Share::App
