class User < ActiveRecord::Base
  has_many :questions
  has_many :countries, through: :questions
  after_initialize :available_questions

  validates :email, presence: true


  def self.total_points(id)
      holder = Question.all.select { |x| x.user_id == id}
      holder.size
  end

  def available_questions
    self.available_questions =
    Category.all.map do |category|
      available_questions = {category.name => Country.all.map {|c| c.name}}
    end
  end


  end
