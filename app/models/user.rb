class User < ActiveRecord::Base
  has_many :questions
  has_many :countries, through: :questions

  validates :email, presence: true

end
