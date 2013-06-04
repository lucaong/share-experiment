require "./deploy/packages/essentials"
require "./deploy/packages/git"
require "./deploy/packages/nginx"
require "./deploy/packages/postgres"
require "./deploy/packages/redis"
require "./deploy/packages/ruby"

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
  end

  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end
