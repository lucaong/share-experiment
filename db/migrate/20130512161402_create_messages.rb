class CreateMessages < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.integer :channel_id
      t.text    :body
      t.string  :author
      t.timestamps
    end
  end

  def down
    drop_table :messages
  end
end
