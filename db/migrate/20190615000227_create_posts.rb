class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :author
      t.string :place
      t.string :description
      t.string :hashtags
      t.integer :likes, default: 0

      t.timestamps
    end
  end
end
