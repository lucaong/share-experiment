require "sinatra/base"
require "sinatra/activerecord"
require "sinatra/contrib"
require "erb"
require "sprockets"
require "sinatra/sprockets-helpers"
require "./lib/share/channel"
require "./lib/share/message"

module Share
  class App < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::Contrib

    set :database, ENV["DATABASE_URL"] || "sqlite3:///share.sqlite3"
    set :root, "./"
    set :public_folder, "./public"

    # asset pipeline
    register Sinatra::Sprockets::Helpers
    set :sprockets, Sprockets::Environment.new
    set :assets_prefix, "/assets"
    set :assets_path, -> { File.join( public_folder, assets_prefix ) }
    set :digest_assets, production?
    configure_sprockets_helpers
    configure do
      sprockets.append_path "assets/images"
      sprockets.append_path "assets/stylesheets"
      sprockets.append_path "assets/javascripts"
    end

    # test
    post "/test" do
      logger.info params.inspect
      "Received POST with params: #{params.inspect}"
    end
    get "/test" do
      logger.info params.inspect
      "Received GET with params: #{params.inspect}"
    end

    # home
    get "/" do
      if params[:slug].nil?
        respond_with :home
      else
        redirect to("/#{params[:slug]}")
      end
    end

    # show channel
    get "/:slug" do
      channel = Channel.find_by_slug params[:slug]
      respond_with :show, channel: channel
    end

    # create new channel
    post "/" do
      channel = Channel.create
      respond_with :show, channel: channel do |type|
        type.html { redirect to("/#{channel.slug}") }
      end
    end

    # create new message in channel
    post "/:slug" do
      pubsub  = pubsub_client(request)
      slug    = params[:slug]
      channel = Channel.find_by_slug slug

      raise "Channel '#{slug}' not found" if not channel

      message = channel.push_message(
        "body"   => params[:body],
        "author" => params[:author]
      )
      pubsub.publish( "/channels/#{slug}", message.to_h )
      respond_with :show, channel: channel do |type|
        type.json { message.to_json }
      end
    end

    private

    def pubsub_client(request)
      Faye::Client.new( "#{request.base_url}/faye" )
    end
  end
end
