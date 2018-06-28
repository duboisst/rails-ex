# Cette classe représente un canal de distribution.
#
# Les bons de livraisons sont associés à un canal via leur nom de fichier.
#
# Les canaux sont associés aux utilisateurs via leur profil.
#
# Les canaux permettent donc de filtrer les bons en fonction des autorisations de l'utilisateur
#
# schema.rb snippet:
#  create_table "channels", :force => true do |t|
#    t.string   "code"
#    t.string   "name"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
class Channel < ActiveRecord::Base
  attr_accessible :code, :name, :created_at, :updated_at
  has_and_belongs_to_many :profiles
  
  validates_presence_of :code, :name
  validates_uniqueness_of :code, :name
  
  before_destroy do |channel|
    raise "profiles does exist !" if !channel.profiles.empty?
  end

end
