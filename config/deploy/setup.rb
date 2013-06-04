# run with:
#   STAGE=<development|production> sprinkle -s config/deploy/setup.rb
#

require "./config/deploy/packages/essentials"
require "./config/deploy/packages/git"
require "./config/deploy/packages/nginx"
require "./config/deploy/packages/postgres"
require "./config/deploy/packages/redis"
require "./config/deploy/packages/ruby"

policy :appserver, :roles => :app do
  requires :essentials
  requires :version_control
  requires :webserver
  requires :database
  requires :redis
  requires :ruby
end

deployment do
  delivery :capistrano do
    recipes 'deploy'
    recipes "config/deploy/#{ENV['STAGE'] || 'development'}"
  end

  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end
