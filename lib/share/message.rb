# encoding: utf-8
require "redis"
require "uri"
require "onebox"

module Share
  class Message
    attr_accessor :body, :author, :created_at, :id
    EXPIRATION_TIME = 60 * 60 * 3 # messages expire after 3 hours

    module ClassMethods
      def all_in_channel( channel )
        ids_key = redis_ids_key( channel.id )
        ids     = redis.zrange ids_key, 0, -1
        return [] if ids.empty?

        keys      = ids.map { |i| redis_key( channel.id, i ) }
        messages  = []

        redis.mget( *keys ).each do |raw|
          messages << new( JSON.parse( raw ) ) if raw
        end
        messages
      end

      def redis_ids_key( channel_id )
        "shareapp:channels:#{channel_id}:message_ids"
      end

      def redis_key( channel_id, message_id )
        "shareapp:channels:#{channel_id}:messages:#{message_id}"
      end

      def redis
        uri = URI.parse( ENV["REDISTOGO_URL"] || "http://localhost:6379" )
        @_redis ||= Redis.new(
          host: uri.host,
          port: uri.port,
          password: uri.password
        )
      end
    end

    extend ClassMethods

    def to_h
      {
        body:       body,
        author:     author,
        created_at: created_at
      }
    end

    def to_json
      to_h.to_json
    end

    def initialize( attrs )
      @body       = attrs["body"]
      @author     = attrs["author"]
      @created_at = attrs["created_at"]
    end

    def persist_to_channel!( channel )
      process!
      self.created_at = Time.now.utc
      ids_key = self.class.redis_ids_key( channel.id )
      id = SecureRandom.uuid
      redis.multi do
        key = self.class.redis_key( channel.id, id )
        redis.setex key, EXPIRATION_TIME, to_json
        redis.zadd ids_key, Time.now.utc.to_i, id
        redis.expire ids_key, EXPIRATION_TIME
      end
    end

    private

    def redis
      self.class.redis
    end

    def process!
      self.body = body.slice(0, 1000)
      escape_html!( body )

      map_urls!( body ) do |url|
        result = nil
        result ||= onebox_preview( url )
        result ||= link_url( url )
        result ||= url
        result
      end

      link_twitter_usernames!( body )
      link_email_addresses!( body )

      self.author = author.slice(0, 50)
      escape_html!( author )
      link_twitter_usernames!( author )
    end

    def escape_html!( text )
      # Escape html (but leave slashes)
      text.gsub! /&|<|>|'|"/ do |c|
        escaped = {
          "&"=>"&amp;",
          "<"=>"&lt;",
          ">"=>"&gt;",
          "'"=>"&#x27;"
        }
        escaped[c]
      end
      text
    end

    def link_twitter_usernames!( text )
      text.gsub! /(^|\s)@(\w+)/ do
        "#{$1}<a href='https://twitter.com/#{$2}' target='_blank'>@#{$2}</a>"
      end
      text
    end

    def link_email_addresses!( text )
      text.gsub! /(\b)([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})(\b)/i do
        "#{$1}<a href='mailto:#{$2}'>#{$2}</a>#{$3}"
      end
      text
    end

    def map_urls!( text )
      # Decorate URLs. RegExp pattern from:
      # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
      url_regexp = /(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/
      text.gsub!( url_regexp ) { |orig| yield orig }
      text
    end

    def link_url( orig )
      url = orig
      url = "http://#{url}" unless url.match /^[a-z][\w-]+:/
      "<a href='#{url}' target='_blank'>#{orig}</a>"
    end

    def onebox_preview( url )
      matcher = Onebox::Matcher.new( url )

      if matcher.oneboxed
        Onebox.preview( url ).to_s
      else
        nil
      end
    end
  end
end
