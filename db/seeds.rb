account = Account.find_or_create_by!(name: "LiteLink") do |a|
  a.plan = "light"
end

User.find_or_create_by!(email: "patrikjira@gmail.com") do |u|
  u.account = account
  u.name = "Patrik Jíra"
  u.password = "password123"
  u.role = "manager"
end

puts "Seed complete: patrikjira@gmail.com / password123 (manager)"
