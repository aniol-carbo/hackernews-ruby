class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
       t.string :text
      t.boolean :escomment
      t.integer :points, default: 1
      t.integer :user, null: false
      t.integer :contribution, null: false
      t.integer :comment_id
      t.timestamps null: false
    end
  end
end
