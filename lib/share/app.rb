require "sinatra/base"
require "sinatra/activerecord"
require "sinatra/contrib"
require "./lib/share/channel"
require "./lib/share/message"

module Share
  class App < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::Contrib
    set :database, "sqlite3:///share.sqlite3"

    post "/test" do
      puts params.inspect
      params.inspect
    end

    get "/test" do
      puts params.inspect
      params.inspect
    end

    # show channel
    get "/:slug" do
      channel = Channel.find_by_slug params[:slug]
      respond_with :show, channel: channel
    end

    # create new channel
    post "/" do
      channel = Channel.create
      respond_with :index, channels: Channel.all
    end

    # create new message in channel
    post "/:slug" do
      channel = Channel.find_by_slug params[:slug]
      message = channel.messages.create body: params[:body]
      respond_with :show, channel: channel
    end
  end
end
