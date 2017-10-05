# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# ['admin', 'user'].each do |a|
#   role = Role.find_or_create_by(name: a)
#   User.create(email: "#{a}@example.com", password: 'password', password_confirmation: 'password', role_id: role.id) unless User.find_by(email: "#{a}@example.com")
# end