module Share
  class Message < ActiveRecord::Base
    belongs_to :channel

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
  end
end
