require "bundler/setup"
require "./lib/share"
require "faye"

map "/assets" do
  run Share::App.sprockets
end

Faye::WebSocket.load_adapter('thin')

use Faye::RackAdapter, mount: "/faye", timeout: 25

run Share::App
