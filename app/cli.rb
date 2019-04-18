class CLI

  def initialize
    @prompt = TTY::Prompt.new
    @password = nil
  end

# Displays the start menu
  def start_menu
    puts ""
    choice = @prompt.select("Welcome! Please choose from the following options:") do |menu|
      menu.choice 'Play'
      menu.choice 'Account Management'
      menu.choice 'Check Scoreboard'
      menu.choice "Exit"
    end

  if choice == "Play"
    if @user
      play
    else
      login
      play
    end
  elsif choice == "Account Management"
    manage_account
  elsif choice == "Check Scoreboard"
    scoreboard
  elsif choice == "Exit"
    system 'killall afplay'
    goodbye
  end
end

def login
  puts ""
  puts "Please login to your account."
  email = @prompt.ask("What's your email?")
  if @user = User.find_by(email: email)
    @user = User.find_by(email: email)
    puts ""
    password = @prompt.mask("Please insert your password:".green)
    if @user.authenticate(password)
      @password = password
      puts ""
      puts "Welcome back #{@user.name}.".green
      puts ""
    else
      puts ""
      puts "This password is incorrect.".red
      puts ""
      password = @prompt.mask("Please reinsert your password:".red)
      if @user.authenticate(password)
        puts ""
        puts "Welcome back #{@user.name}.".green
        puts ""
      else
        puts ""
        puts "Sorry, this password is still incorrect.".red
        puts "Please go away and check your password!"
        puts ""
        system exit
      end
    end
  else
    puts "**************"
    puts "We could not retrieve your account.".yellow
    puts "It seems like you have never played!".yellow
    puts "**************"
    if @prompt.yes?("Would you like to create an account?")
      puts ""
      create_account
    else
      start_menu
    end
  end
end

# Plays a audio greeting
  def say_greeting
    system 'say "Good Luck"'
  end

# Produces and shows a scoreboard with all users sorted by number of points
  def scoreboard
    existing_users_ids = User.all.map {|user| if user.email != "!!!" then user.id end}.compact
    existing_users_names = User.all.map {|user| if user.email != "!!!" then user.name end}.compact
    existing_users_questions =
    existing_users_ids.map do |id|
      Question.all.select {|question| question.user_id == id}
    end
    users_points = existing_users_questions.map {|user_questions| user_questions.length}
    scoreboard = []
    existing_users_names.each do |name|
      array = []
      array << name
      array << users_points[existing_users_names.index(name)]
      scoreboard << array
    end
    scoreboard = scoreboard.sort_by {|element| element[1]}.reverse
    table = TTY::Table.new ['Player','Points'], scoreboard

    puts ""
    if @user
      user_array = scoreboard.map {|user| if user[0] == @user.name then user end}.compact[0]
      user_position = scoreboard.index(user_array) + 1
      puts ""
      puts "You are no. #{user_position} in the overall score of Country Trivia!".blue
      puts ""
      puts table.render(:ascii)
      sleep(2)
      start_menu
    else
      puts ""
      puts table.render(:ascii)
      sleep(2)
      start_menu
    end
  end

  def play
    say_greeting
    welcome
    formulate_question
  end

# Welcomes a user before starting a game session.
  def welcome
    puts ""
    puts "Welcome, your score will be saved to #{@user.email}.".yellow
    puts ""
    puts "You have #{@user.questions.length} points."
    sleep(2)
  end

# Creates a question from the database and initiates a game round
  def formulate_question
    @category = @user.available_questions.sample.keys
    @category_instance = Category.all.select {|cat| cat.name == @category[0]}
    category_hash = @user.available_questions.select {|h| h.keys == @category}
    @country = category_hash[0].values[0].sample
    @country_instance = Country.all.select {|cou| cou.name == @country}
    pose_question
  end

  def pose_question
    @question = "#{@category_instance[0].text} #{@country}?"
    puts "Category: ".blue + "#{@category[0].capitalize}"
    puts "Question: ".blue + "#{@question}"
    puts ""
    update_user_questions
    get_correct_answer
  end

  def update_user_questions
    @user.update_questions(@category[0], @country, @password)
  end

  def get_correct_answer
    response_string = RestClient.get("https://restcountries.eu/rest/v2/alpha/#{@country_instance[0].code}")
    country_info = JSON.parse(response_string)

    if @category_instance[0].name == "capital"
      @answer = country_info["capital"].downcase
      @correct_answer = country_info["capital"].downcase
    elsif @category_instance[0].name == "currency"
      @answer = country_info["currencies"][0]["name"].downcase
      @correct_answer = country_info["currencies"][0]["name"].downcase
    else
      @answer = country_info["languages"][0]["name"].downcase
      @correct_answer = country_info["languages"][0]["name"].downcase
    end
    get_user_answer
  end

  def get_user_answer
    guess = gets.chomp.downcase.strip
    if guess == @answer
      puts ""
      puts "Well done, your score has increased by 1 point.".blue
      Question.create(user_id: @user.id, category_id: @category_instance[0].id, country_id: @country_instance[0].id)
      puts ""
      puts "You now have #{@user.questions.reload.length} points."
      puts ""
      update_user_questions
      continue_play?
    else
      puts ""
      puts "Unfortunately your answer was incorrect. The correct answer was #{if @answer == nil then "" else @correct_answer.titleize end}.".red
      puts ""
      puts "You have #{@user.questions.length} points."
      puts ""
      update_user_questions
      continue_play?
    end
  end

  def continue_play?
    if @prompt.yes?("Would you like to continue playing?".blue)
      formulate_question
    else
      puts ""
      puts "Thanks for playing!".yellow
      puts ""
      start_menu
    end
  end

# Provides roadmap for account management
  def manage_account
    if @user
      manage_account_menu
    else
      login
      manage_account_menu
    end
  end

# Gives options to manage account
def manage_account_menu
  choice = @prompt.select("Please choose from the following options:") do |menu|
    menu.choice 'Change my name'
    menu.choice 'Change my password'
    menu.choice 'Delete my account'.blue
    menu.choice "Back to Main Menu"
  end

  if choice == "Change my name"
    change_name
  elsif choice == "Change my password"
    change_password
  elsif choice == "Delete my account".blue
    delete_account
  elsif choice == "Back to Main Menu"
    start_menu
  end
end

def change_name
  new_name = @prompt.ask("What's your name?")
  @user.update(name: new_name, password: @password)
  # @user.save
  puts ""
  puts "Your name was changed to #{new_name}."
  puts ""
  manage_account_menu
end

def change_password
  new_password = @prompt.mask("Please set a new password:".green)
  new_password_reenter = @prompt.mask("Please reenter your new password:".green)
  if new_password == new_password_reenter
    @user.password = new_password
    @user.save
    puts ""
    puts "Your password has been successfully changed.".blue
    puts ""
    manage_account_menu
  else
    puts "The pass do not match."
    new_password_reenter = @prompt.mask("Please reenter your new password:".green)
    if new_password == new_password_reenter
      @user.password = new_password
      @user.save
      puts ""
      puts "Your password has been successfully changed.".blue
      puts ""
      manage_account_menu
    else
      puts ""
      puts "Your passwords do not match."
      puts "Please try again later."
      manage_account_menu
    end
  end
end

def delete_account
  if @prompt.yes?("Are you sure you want to delete your account. ALL YOUR POINTS AND PROGRESS WILL BE LOST!".red)
    @user.destroy
  else
    manage_account
  end
end

# Creates a new user account.

def create_account
  puts ""
  puts "Let's create your account!"
  puts ""
  name = @prompt.ask("What's your name?")
  email = @prompt.ask("What's your email?")
  password = @prompt.mask("Please create a password:".green)
  password_reenter = @prompt.mask("Please confirm your password:".green)
  if password == password_reenter
    @user = User.new(name: name.titleize.strip, email: email, password: password)
    @user.save
    sleep(2)
    puts ""
    puts "Thanks for creating your account.".blue
    puts ""
    sleep(1)
    start_menu
  else
    puts "The passwords do not match.".red
    password = @prompt.mask("Please reenter your password:".red)
    password_reenter = @prompt.mask("Please confirm your password:")
    if password == password_reenter
      @user = User.new(name: name.titleize.strip, email: email, password: password)
      @user.save
      sleep(2)
      puts ""
      puts "Thanks for creating an account.".blue
      puts ""
      sleep(1)
      start_menu
    else
      puts ""
      puts "The passwords do not match.".red
      puts "Please try again later.".red
      system exit
    end
  end
end

# Says goodbye to the user
  def goodbye
    return "Thanks for playing! See you soon!".yellow
    system exit
  end

# Displays game name in splash text

  def display_splash_text
    splash = Artii::Base.new :font => 'slant'
    puts splash.asciify('Country Trivia').blue
    splash
  end

# Sound method using afplay
  def play_sound
    system 'afplay /Users/Nahit/Desktop/mod1/mod1_project/app/sounds/test_sound.mp3 &'
  end


# Runner method.
def run
  display_splash_text
  play_sound
  start_menu
end

end
