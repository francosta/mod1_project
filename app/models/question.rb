class Question < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :category

end
