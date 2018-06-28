# Cette classe représente un profil utilisateur.
#
# Les profils sont associés aux utilisateur.
#
# Un profil est lié à un on plusieurs canaux de distribution via la table channels_profiles
#
# schema.rb snippet:
#  create_table "channels_profiles", :id => false, :force => true do |t|
#    t.integer  "profile_id", :limit => 11
#    t.integer  "channel_id", :limit => 11
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#
#  add_index "channels_profiles", ["channel_id"], :name => "channel_id"
#  add_index "channels_profiles", ["profile_id"], :name => "profile_id"
#
#  create_table "profiles", :force => true do |t|
#    t.string   "name"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
class Profile < ActiveRecord::Base
  has_and_belongs_to_many :channels
  attr_accessible :channel_ids

  has_many :users

  attr_accessible :name, :created_at, :updated_at
  
  validates_presence_of :name 
  validates_uniqueness_of :name
  
  before_destroy do |profile|
    raise "it does exist users with this profile !" if !profile.users.empty?
  end  
end
