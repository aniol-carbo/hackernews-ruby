class Tweet < ApplicationRecord
  def change
    add_column :title, :url, :text
  end
end
