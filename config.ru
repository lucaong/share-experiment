require "bundler/setup"
require "./lib/share"
require "sprockets"
require "faye"

map "/assets" do
  assets = Sprockets::Environment.new
  assets.append_path "assets/images"
  assets.append_path "assets/stylesheets"
  assets.append_path "assets/javascripts"
  run assets
end

Faye::WebSocket.load_adapter('thin')

use Faye::RackAdapter, mount: "/faye", timeout: 25

run Share::App
