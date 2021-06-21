class AddUpdatedAtToTweetModel < ActiveRecord::Migration[6.1]
  def change
    add_column :tweets, :updated_at, :datetime
  end
end
