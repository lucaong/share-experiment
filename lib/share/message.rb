module Share
  class Message < ActiveRecord::Base
    belongs_to :channel
    before_create :markup_body

    def as_json(options = {})
      return {
        body:       body,
        author:     author,
        created_at: created_at
      }
    end

    private

    def markup_body
      # Escape html (but not slashes)
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
    end
  end
end
