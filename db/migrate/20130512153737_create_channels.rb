class CreateChannels < ActiveRecord::Migration
  def up
    create_table :channels do |t|
      t.string :slug
      t.timestamps
    end

    add_index :channels, :slug, unique: true
  end

  def down
    remove_index :channels, column: :slug
    drop_table :channels
  end
end
