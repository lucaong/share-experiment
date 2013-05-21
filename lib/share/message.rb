require "redis"

module Share
  class Message
    attr_accessor :body, :author, :created_at, :id

    module ClassMethods
      def all_in_channel( channel )
        ids = redis.zrange redis_ids_key( channel.id ), 0, -1
        return [] if ids.empty?
        keys = ids.map { |i| redis_key( channel.id, i ) }
        redis.mget( *keys ).map do |raw|
          new JSON.parse( raw )
        end
      end

      def redis_ids_key( channel_id )
        "shareapp:channels:#{channel_id}:message_ids"
      end

      def redis_key( channel_id, message_id )
        "shareapp:channels:#{channel_id}:messages:#{message_id}"
      end

      def redis
        @_redis ||= Redis.new
      end
    end

    extend ClassMethods

    def to_json
      return {
        body:       body,
        author:     author,
        created_at: created_at
      }.to_json
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
        redis.mset key, to_json
        redis.zadd self.class.redis_ids_key( channel.id ), Time.now.utc.to_i, id
      end
    end

    private

    def redis
      self.class.redis
    end

    def process!
      # Escape body (but leave slashes)
      body.gsub! /&|<|>|'|"/ do |c|
        escaped = {
          "&"=>"&amp;",
          "<"=>"&lt;",
          ">"=>"&gt;",
          "'"=>"&#x27;"
        }
        escaped[c]
      end

      # Decorate URLs. RegExp pattern from:
      # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
      url_regexp = /(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/
      body.gsub! url_regexp do |orig|
        url = orig
        url = "http://#{url}" unless url.match /^[a-z][\w-]+:/
        "<a href='#{url}' target='_blank'>#{orig}</a>"
      end

      # Decorate Twitter handles
      body.gsub! /(^|\s)@(\w+)/ do
        "#{$1}<a href='https://twitter.com/#{$2}' target='_blank'>@#{$2}</a>"
      end

      # Decorate email addresses
      body.gsub! /(\b)([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})(\b)/i do
        "#{$1}<a href='mailto:#{$2}'>#{$2}</a>#{$3}"
      end

      # Escape author
      author = Rack::Utils.escape_html( author )
    end
  end
end
