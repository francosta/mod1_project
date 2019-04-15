class Category < ActiveRecord::Base
  has_many :questions
  has_many :users, through: :questions
  has_many :countries, through: :questions
end
