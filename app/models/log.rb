# Cette classe représente les logs des recherches effectuée.
#
class Log < ActiveRecord::Base
  belongs_to :user
  serialize :params
  attr_accessible :action, :created_at, :updated_at, :params, :user_id
end
