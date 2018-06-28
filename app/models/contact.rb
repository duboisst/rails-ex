class Contact < ActiveRecord::Base
  attr_accessible :name, :tel, :address, :info, :created_at, :updated_at
end
