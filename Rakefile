require "sinatra/activerecord/rake"
require "./lib/share/app"

namespace :assets do
  desc "Precompile assets"
  task :precompile do
    env = Share::App.sprockets
    manifest = Sprockets::Manifest.new(env.index, Share::App.assets_path)
    manifest.compile %w(application.js application.css *.png *.jpg)
  end

  desc "Clean assets"
  task :clean do
    FileUtils.rm_rf(Share::App.assets_path)
  end
end
