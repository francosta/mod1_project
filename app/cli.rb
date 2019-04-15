  def find_or_create_user
    email = @prompt.ask("What's your email?")
    @user = User.find_or_create(email: email)
  end

  def welcome
    puts "Welcome, your score will be saved to #{@user.email}. Let's start playing!"
  end
  #
  # def play
  #   country = Country.all.sample
  #   category = Category.all.sample
  #   question = "#{category.text} #{country.name}?"
  #   answer

  # def create_countries
  #   COUNTRIES_ARRAY.each {|country| Country.create(name:country[:name], code: country[:code])}
  # end
