class CLI

  def initialize
    @prompt = TTY::Prompt.new
  end

  def start_menu
    choice = @prompt.select("Welcome! Please choose from the following options:") do |menu|
      menu.choice 'Play'
      menu.choice 'Account Management'
      menu.choice 'Check Scoreboard'
      menu.choice "Exit"
    end

  if choice == "Exit"
    goodbye
  elsif choice == "Play"
    say_greeting
    find_or_create_user
    welcome
    formulate_question
  elsif choice == "Check Scoreboard"
    puts "Feature coming soon"
  elsif choice == "Account Management"
    puts "Feature coming soon"
  end

  end

  def say_greeting
    system 'say "Good Luck"'
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

  # formulate question
    category = @user.available_questions.sample.keys
    category_instance = Category.all.select {|cat| cat.name == category[0]}
    category_hash = @user.available_questions.select {|h| h.keys == category}

    country = category_hash[0].values[0].sample
    country_instance = Country.all.select {|cou| cou.name == country}

  # pose question
    question = "#{category_instance[0].text} #{country}?"
    puts question

  # update user questions
    @user.update_questions(category[0], country)

  # get correct answer
    response_string = RestClient.get("https://restcountries.eu/rest/v2/alpha/#{country_instance[0].code}")
    country_info = JSON.parse(response_string)

    if category_instance[0].name == "capital"
      answer = country_info["capital"]
    elsif category_instance[0].name == "currency"
      answer = country_info["currencies"][0]["name"]
    else
      answer = country_info["languages"][0]["name"]
    end

  # get answer from user
    guess = gets.chomp
    if guess == answer
      puts "Well done, your score has increased +1"
      Question.create(user_id: @user.id, category_id: category_instance[0].id, country_id: country_instance[0].id)
      puts "You now have #{@user.questions.reload.length} points."
      if @prompt.yes?("Would you like to continue playing?")
        formulate_question
      else
        goodbye
      end
    else
      puts "Unfortunately your answer was incorrect."
      puts "You have #{@user.questions.length} points."
      if @prompt.yes?("Would you like to continue playing?")
        formulate_question
      else
        goodbye
      end
    end
  end

#   def manage_account
#
#     choice = @prompt.select("Please choose from the following options:") do |menu|
#       menu.choice 'Change my name'
#       menu.choice 'Change my password'
#       menu.choice 'Delete my account'
#       menu.choice "Back to Main Menu"
#     end
#
#   if choice == "Change my name"
#     new_name =
#
#     email = @prompt.ask("What's your email?")
#     @user = User.find_or_create_by(email: email)
#
#   elsif choice == "Play"
#     find_or_create_user
#   elsif choice == "Check Scoreboard"
#     puts "Feature coming soon"
#   elsif choice == "Account Management"
#     puts "Feature coming soon"
#   end
#
# end


# says goodbye to the user
  def goodbye
    puts "Thanks for playing! See you soon!"
  end

  def display_splash_text
    splash = Artii::Base.new :font => 'slant'
    puts splash.asciify('Guessing Game')
    splash
  end

  def run
    display_splash_text
    start_menu
  end
end
