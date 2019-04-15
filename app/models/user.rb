class User < ActiveRecord::Base
  has_many :questions
  has_many :countries, through: :questions

  validates :name, presence: true
  validates :email, presence: true

end
