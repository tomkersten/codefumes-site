Sham.define do
  title       {Faker::Lorem.words(4).join(' ')}
  body        {Faker::Lorem.paragraphs(3).join('\n\n')}
  email       {Faker::Internet.email}
  user_name   {Faker::Internet.user_name}
  name        {Faker::Name.name}
  public_key  {Digest::SHA1.hexdigest(Time.now.to_s + Kernel.rand(1000).to_s)[0..5]}
end

# START: User blueprints
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
  email "oscar@haxit.com"
  login "oscar.opensource"
end

User.blueprint(:dora) do
  email "dora@midco.com"
  login "dora.developer"
end
# END: User blueprints

# START: Project blueprints
Project.blueprint do
  name        {Faker::Lorem.words(2).join(' ')}
  public_key
end
