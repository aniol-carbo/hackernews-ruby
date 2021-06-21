class UpdateTweets2 < ActiveRecord::Migration[6.1]
  def change
    add_column :tweets, :ask, :boolean, :default => false
  end
end
