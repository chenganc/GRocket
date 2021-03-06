# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create!(firstName:  "Admin",
             lastName:  "User",
             email: "admin@example.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  firstName = Faker::Name.first_name
  lastName  = Faker::Name.last_name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(firstName: firstName,
              lastName:  lastName,
              email: email,
              password:              password,
              password_confirmation: password,
              activated: true,
              activated_at: Time.zone.now)
  #if n < 9
  #  Link.create!(title: "hello from #{firstName}",
  #               course: "CMPT#{n+1}",
  #               department: "CMPT",
  #               body: "Hello world!",
  #               user_id: "#{n+2}")
  #end
end

# Posts
#users = User.order(:created_at).take(6)
#50.times do
#  content = Faker::Lorem.sentence(5)
#  users.each { |user| user.microposts.create!(content: content) }
#end

# Following relationships
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
