require 'pry'

User.destroy_all
Country.destroy_all
Question.destroy_all

COUNTRIES_ARRAY.each {|country| Country.create(name: country[:name], code: country[:code])}

User.create(name: "Nahit", email: "nahit@gmail.com")
User.create(name: "Fran", email: "fran@gmail.com")
