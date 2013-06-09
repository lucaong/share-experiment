# run with:
#   STAGE=<development|production> sprinkle -s config/deploy/setup.rb
#

require File.expand_path("../settings.rb", File.dirname(__FILE__))
STAGE = ENV['STAGE'] || 'development'

require "./config/deploy/packages/essentials"
require "./config/deploy/packages/git"
require "./config/deploy/packages/nginx"
require "./config/deploy/packages/postgres"
require "./config/deploy/packages/redis"
require "./config/deploy/packages/ruby"

policy :appserver, :roles => :app do
  requires :essentials
  requires :version_control
  requires :webserver,
    :domain    => SETTINGS[STAGE.to_sym][:domain],
    :root_path => SETTINGS[:deploy_to]
  requires :database
  requires :redis
  requires :ruby, :ruby_version => SETTINGS[:ruby_version]
end

deployment do
  delivery :capistrano do
    recipes 'deploy'
    recipes "config/deploy/#{STAGE}"
  end

  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end
