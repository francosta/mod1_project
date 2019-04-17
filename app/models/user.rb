class User < ActiveRecord::Base
  has_many :questions
  has_many :countries, through: :questions
  after_initialize :available_questions

  validates :email, presence: true
  validates :password, presence: true

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

  def update_questions(category, country)
    questions =
    Category.all.map do |category|
      available_questions = {category.name => Country.all.map {|c| c.name}}
    end

    category_hash = questions.select {|hash| hash.keys[0] == category}

    category_hash[0].values[0].delete(country)
    self.update(available_questions: questions)

  end
end
