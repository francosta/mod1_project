require 'pry'



#
# u1 = User.create(name: "Nahit", email: "nahit@gmail.com")
# u2 = User.create(name: "Fran", email: "fran@gmail.com")
#
# q1 = Question.create(country: c1, category: cat1)
# q2 = Question.create(country:c1, category:cat2)
# q3 = Question.create(country:c2, category:cat1)b
# q4 = Question.create(country:c2, category:cat2)
COUNTRIES_ARRAY.each {|country| Country.create(name: country[:name], code: country[:code])}
