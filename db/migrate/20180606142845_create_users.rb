class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string   "login"
      t.string   "name"
      t.boolean  "all_channels",                 :precision => 1,  :scale => 0
      t.boolean  "is_admin",                     :precision => 1,  :scale => 0
      t.integer  "profile_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "dn",           :limit => 2000
      t.timestamps
    end
  end
end
