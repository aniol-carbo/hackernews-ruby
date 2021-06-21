class RemoveUpdatedAtFromTweets < ActiveRecord::Migration[6.1]
  def change
    remove_column :tweets, :updated_at, :datetime
  end
end
