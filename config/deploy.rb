set :stages, %w(production development)
set :default_stage, "development"
set :deploy_to, "/var/www/apps/#{application}"

require "capistrano/ext/multistage"
