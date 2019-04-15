

u1 = User.create(name: "Nahit", email: "nahit@gmail.com")
u2 = User.create(name: "Fran", email: "fran@gmail.com")

c1 = Country.create(name: "United Kingdom", code:"GB")
c2 = Country.create(name: "Portugal", code:"PT")

cat1 = Category.create(name:"Capital City", text: "What's the capital of")
cat2 = Category.create(name:"Currency", text: "What's the currency of")

q1 = Question.create(country: c1, category: cat1)
q2 = Question.create(country:c1, category:cat2)
q3 = Question.create(country:c2, category:cat1)
q4 = Question.create(country:c2, category:cat2)
