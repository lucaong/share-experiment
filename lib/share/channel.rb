module Share
  class Channel < ActiveRecord::Base
    before_create :set_slug
    has_many :messages

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
