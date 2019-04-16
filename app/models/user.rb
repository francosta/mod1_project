class User < ActiveRecord::Base
  has_many :questions
  has_many :countries, through: :questions

  validates :email, presence: true

  def self.total_points(id)
      holder = Question.all.select { |x| x.user_id == id}
      holder.size
  end


  end
