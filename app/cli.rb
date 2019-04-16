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
    puts "You have #{@user.questions.length} points."
  end

  def formulate_question

    category = @user.available_questions.sample.keys
    category_instance = Category.all.select {|cat| cat.name == category[0]}
    category_hash = @user.available_questions.select {|h| h.keys == category}

    country = category_hash[0].values[0].sample
    country_instance = Country.all.select {|cou| cou.name == country}

    question = "#{category_instance[0].text} #{country}?"
    puts question

    category_hash[0].values[0].delete(country)
    # @user.reload
  # end

  # def get_answer
    response_string = RestClient.get("https://restcountries.eu/rest/v2/alpha/#{country_instance[0].code}")
    country_info = JSON.parse(response_string)

    if category_instance[0].name == "capital"
      answer = country_info["capital"]
    elsif category_instance[0].name == "currency"
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
      Question.create(user_id: @user.id, category_id: category_instance[0].id, country_id: country_instance[0].id)
      puts "You now have #{@user.questions.reload.length} points."
      if @prompt.yes?("Would you like to continue playing?")
        formulate_question
      # else
      #   goodbye
      end
    else
      puts "Unfortunately your answer was incorrect."
      puts "You have #{@user.questions.length} points."
      if @prompt.yes?("Would you like to continue playing?")
        formulate_question
      # else
      #   goodbye
      end
    end
  end

  def run
    find_or_create_user
    welcome
    formulate_question
  end
end
