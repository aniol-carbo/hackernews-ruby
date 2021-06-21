class UpdateUsers7 < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :current_sign_in_ip, :inet
    remove_column :users, :last_sign_in_ip, :inet
  end
end
