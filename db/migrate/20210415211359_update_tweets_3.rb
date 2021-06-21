class UpdateTweets3 < ActiveRecord::Migration[6.1]
  def change
     add_column :tweets, :shorturl, :string
  end
end
