class AddPointsToTweetModel < ActiveRecord::Migration[6.1]
  def change
    add_column :tweets, :points, :integer, :default => 0
  end
end
