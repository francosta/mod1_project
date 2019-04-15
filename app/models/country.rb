class Country < ActiveRecord::Base
  has_many :questions
  has_many :users, through: :questions
end
