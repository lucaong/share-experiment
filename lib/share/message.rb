module Share
  class Message < ActiveRecord::Base
    belongs_to :channel
    before_create :markup_body

    def author
      # TODO: this is a stub
      "Anonymous"
    end

    def as_json(options = {})
      return {
        body:       body,
        author:     author,
        created_at: created_at
      }
    end

    private

    def markup_body
      self.body = Rack::Utils.escape_html(body)

      # Twitter handles
      body.gsub! /(^|\s)@(\w+)/ do
        "#{$1}<a href='https://twitter.com/#{$2}' target='_blank'>@#{$2}</a>"
      end

      # email addresses
      body.gsub! /(\b)([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})(\b)/i do
        "#{$1}<a href='mailto:#{$2}'>#{$2}</a>#{$3}"
      end
    end
  end
end
