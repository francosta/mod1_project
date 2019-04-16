class CLI

  def initialize
    @prompt = TTY::Prompt.new
  end

  def find_or_create_user
    email = @prompt.ask("What's your email?")
    @user = User.find_or_create_by(email: email)
  end

  def welcome
    puts "Welcome, your score will be saved to #{@user.email}. Let's start playing!"
  end

  def formulate_question
    country = Country.all.sample
    category = Category.all.sample
    question = "#{category.text} #{country.name}?"
    puts question
  # end

  # def get_answer

    response_string = RestClient.get("https://restcountries.eu/rest/v2/alpha/#{country.code}")
    country_info = JSON.parse(response_string)

    if category.name == "capital"
      answer = country_info["capital"]
    elsif category.name == "currency"
      answer = country_info["currencies"][0]["name"]
    else
      answer = country_info["languages"][0]["name"]
    end
  #
  # end
  #
  # def answer_question
    guess = gets.chomp
    if guess == answer
      puts "Well done, your score has increased +1"
      Question.create(user_id: @user.id, category_id: category.id, country_id: country.id)
    else
      puts "Unfortunately your answer was incorrect."
    end
  end


  def run
    find_or_create_user
    welcome
    formulate_question
  end
end
