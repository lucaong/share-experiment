require File.expand_path("settings.rb", File.dirname(__FILE__))

set :stages, %w(production development)
set :default_stage, "development"
set :deploy_to, SETTINGS[:deploy_to]

require "capistrano/ext/multistage"
