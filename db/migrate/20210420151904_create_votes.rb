class CreateVotes < ActiveRecord::Migration[6.1]
 def change
    create_table :votes do |t|
      t.string  "tipus", null: false
      t.integer "idType", null: false
      t.integer "idUser", null: false
      t.datetime "created_at"
      t.index ["tipus", "idType", "idUser"], name: "index_vote_on_type_idType_idUser", unique: true
    end
  end
end
