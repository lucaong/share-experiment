module Share
  class Message < ActiveRecord::Base
    belongs_to :channel
  end
end
