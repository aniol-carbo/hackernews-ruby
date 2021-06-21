class AddTextToTweetModel < ActiveRecord::Migration[6.1]
  def change
    add_column :tweets, :text, :string
  end
end
