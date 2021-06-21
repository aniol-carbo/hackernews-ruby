class AddTitleToTweetModel < ActiveRecord::Migration[6.1]
  def change
    add_column :tweets, :title, :string
  end
end
