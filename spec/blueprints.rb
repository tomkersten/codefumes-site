Sham.define do
  title     {Faker::Lorem.words(4).join(' ')}
  body      {Faker::Lorem.paragraphs(3).join('\n\n')}
  email     {Faker::Internet.email}
  user_name {Faker::Internet.user_name}
  name      {Faker::Name.name}
end

User.blueprint do
  login {Sham.user_name}
  email
  password 'password'
  password_confirmation 'password'
end

User.blueprint(:typical_user) do
  # Created named blueprint for clarity in tests
end

User.blueprint(:sam) do
  login "sam.surfer"
  email "sam@flomericabank.com"
end

User.blueprint(:oscar) do
  f.email "oscar@haxit.com"
  f.login "oscar.opensource"
end

User.blueprint(:dora) do
  f.email "dora@midco.com"
  f.login "dora.developer"
end
