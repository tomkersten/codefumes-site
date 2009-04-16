Factory.sequence :email do |n|
  "standard_user_#{n}@example.com"
end

Factory.sequence :login do |n|
  "standard_user_#{n}"
end

Factory.define :typical_user, :class => User do |f|
  f.email { Factory.next(:email) }
  f.login { Factory.next(:login) }
  f.password 'password'
  f.password_confirmation 'password'
end
