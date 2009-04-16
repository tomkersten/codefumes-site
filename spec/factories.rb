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

Factory.define :sam, :class => User do |f|
  f.email "sam@flomericabank.com"
  f.login "sam.surfer"
  f.password 'password'
  f.password_confirmation 'password'
end

Factory.define :oscar, :class => User do |f|
  f.email "oscar@haxit.com"
  f.login "oscar.opensource"
  f.password 'password'
  f.password_confirmation 'password'
end

Factory.define :dora, :class => User do |f|
  f.email "dora@midco.com"
  f.login "dora.developer"
  f.password 'password'
  f.password_confirmation 'password'
end
