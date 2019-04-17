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

    existing_users_ids = User.all.map {|user| if user.email != "!!!" then user.id end}.compact

    existing_users_emails = User.all.map {|user| if user.email != "!!!" then user.email end}.compact

    existing_users_questions =
    existing_users_ids.map do |id|
      Question.all.select {|question| question.user_id == id}
    end

    users_points = existing_users_questions.map {|user_questions| user_questions.length}

    binding.pry
    table = TTY::Table[[existing_users_emails], [users_points]]
    table.render(:basic)

  elsif choice == "Account Management"
    manage_account
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
      answer = country_info["capital"].titleize
    elsif category_instance[0].name == "currency"
      answer = country_info["currencies"][0]["name"].titleize
    else
      answer = country_info["languages"][0]["name"].titleize
    end

  # get answer from user
    guess = gets.chomp.titleize.strip
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

  def manage_account
    email = @prompt.ask("What's your email?")
    if @user = User.find_by(email: email)
      @user = User.find_by(email: email)
    else
      puts "This account doesn't exist."
      start_menu
    end

    choice = @prompt.select("Please choose from the following options:") do |menu|
      menu.choice 'Change my name'
      menu.choice 'Change my password'
      menu.choice 'Delete my account'
      menu.choice "Back to Main Menu"
    end

  if choice == "Change my name"
    new_name = @prompt.ask("What's your name?")
    @user.name = new_name
    @user.save
    puts "Welcome, #{new_name}"
    start_menu
  # elsif choice == "Change my password"
  #   new_password = @prompt.ask("Please set a new password:")
  #   @user.password = new_password
  #   puts "Your password has been changed."
  elsif choice == "Delete my account"
    if @prompt.yes?("Are you sure you want to delete your account. ALL YOUR POINTS AND PROGRESS WILL BE LOST!")
      @user.destroy
    else
      manage_account
    end
  elsif choice == "Back to Main Menu"
    start_menu
  end

end


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
