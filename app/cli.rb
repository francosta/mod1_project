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

  elsif choice == "Account Management"
    manage_account
  end
end

  def say_greeting
    system 'say "Good Luck"'
  end

  def find_or_create_user
    puts ""
    puts "Please login to your account."
    email = @prompt.ask("What's your email?")
    if @user = User.find_by(email: email)
      @user = User.find_by(email: email)
      puts ""
      password = @prompt.mask("Please insert your password:")
      if @user.authenticate(password)
        puts "You've successfully logged in."
        sleep (2)
        puts ""
        puts "Let's play!"
        sleep(2)
      else
        puts ""
        puts "This password is incorrect."
        puts ""
        password = @prompt.mask("Please reinsert your password:")
        if @user.authenticate(password)
          puts "You've successfully logged in."
          sleep (1)
          puts ""
          puts "Let's play!"
          sleep(1)
        else
          puts ""
          puts "Sorry, this password is still incorrect."
          puts "Please go away and check your password!"
          puts ""
          system exit
        end
      end
    else
      puts "It seems like you have never played!
      "
      if @prompt.yes?("Would you like to create an account?")
        "
        Let's create your account!
        "
        name = @prompt.ask("What's your name?")
        email = @prompt.ask("What's your email?")
        password = @prompt.mask("Please create a password:")
        password_reenter = @prompt.mask("Please confirm your password:")
        if password == password_reenter
          @user = User.new(name: name, email: email, password: password)
          @user.save
          sleep(2)
          puts ""
          puts "Thanks for creating your account."
          puts "Let's play!"
          puts ""
        else
          puts "The passwords do not match."
          password = @prompt.mask("Please reenter your password:")
          password_reenter = @prompt.mask("Please confirm your password:")
          if password == password_reenter
            @user = User.new(name: name, email: email, password: password)
            @user.save
            sleep(2)
            puts "
            Thanks for creating an account."
          else
            "
            The passwords do not match.
            Please try again later.
            "
            system exit
          end
        end
      else
        puts "
        Goodbye, then.
        "
        system exit
      end
    end
  end

  def welcome
    puts "Welcome, your score will be saved to #{@user.email}."
    puts ""
    puts "You have #{@user.questions.length} points."
    sleep(2)
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
      puts ""
      puts "Well done, your score has increased by 1 point."
      Question.create(user_id: @user.id, category_id: category_instance[0].id, country_id: country_instance[0].id)
      puts ""
      puts "You now have #{@user.questions.reload.length} points."
      puts ""
      if @prompt.yes?("Would you like to continue playing?")
        formulate_question
      else
        goodbye
      end
    else
      puts "
      Unfortunately your answer was incorrect."
      puts "
      You have #{@user.questions.length} points.
      "
      if @prompt.yes?("Would you like to continue playing?")
        formulate_question
      else
        goodbye
      end
    end
  end

  def manage_account
    sleep(1)
    puts "Please login to your account"
    puts ""
    email = @prompt.ask("What's your email?")
    if @user = User.find_by(email: email)
      @user = User.find_by(email: email)
      password = @prompt.mask("Please insert your password:")
      if @user.authenticate(password)
        puts ""
        puts "You've successfully logged in to your account."
        puts ""
        sleep(1)
      else
        puts "The password you entered is incorrect."
        puts ""
        sleep(1)
        password = @prompt.mask("Please try to insert your password again:")
        if @user.authenticate(password)
        else
          sleep(1)
          puts "The password you entered is incorrect."
          puts "Please return later."
          system exit
        end
      end
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
  elsif choice == "Change my password"
    new_password = @prompt.mask("Please set a new password:")
    new_password_reenter = @prompt.mask("Please reenter your new password:")
    @user.password = new_password
    @user.save
    puts ""
    puts "Your password has been successfully changed."
    puts ""
    start_menu
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
    return "Thanks for playing! See you soon!"
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
