class ChangePointsTweetModel < ActiveRecord::Migration[6.1]
  def change
    remove_column :tweets, :points, :integer
    add_column :tweets, :points, :integer, :default => 0
  end
end
