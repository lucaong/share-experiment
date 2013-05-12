module Share
  class Message < ActiveRecord::Base
    belongs_to :channel

    def author
      # TODO: this is a stub
      "Anonymous"
    end
  end
end
