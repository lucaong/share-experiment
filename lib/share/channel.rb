module Share
  class Channel < ActiveRecord::Base
    before_create :set_slug
    #has_many :messages

    def messages
      Message.all_in_channel( self )
    end

    def push_message( message_hash )
      message = Message.new( message_hash )
      message.persist_to_channel!( self )
      message
    end

    private

    def set_slug
      if slug.nil?
        # TODO: this can probably be improved. There is a slight chanche of
        # collision, but I guess that statistically a check may not make sense
        # (and the unique index prevents unwanted consequences)
        self.slug = SecureRandom.base64.delete("/+=")[0,6]
      end
    end
  end
end
