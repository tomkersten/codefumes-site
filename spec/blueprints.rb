Sham.define do
  title       {Faker::Lorem.words(4).join(' ')}
  body        {Faker::Lorem.paragraphs(3).join('\n\n')}
  email       {Faker::Internet.email}
  user_name   {Faker::Internet.user_name}
  name        {Faker::Name.name}
  public_key  {Digest::SHA1.hexdigest(Time.now.to_s + Kernel.rand(1000).to_s)[0..5]}
  private_key {Project.generate_private_key}
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
  email "oscar@haxit.com"
  login "oscar.opensource"
end

User.blueprint(:dora) do
  email "dora@midco.com"
  login "dora.developer"
end

Project.blueprint do
  name        {Faker::Lorem.words(2).join(' ')}
  public_key
  private_key
end

Project.blueprint(:private) do
  name        {Faker::Lorem.words(2).join(' ')}
  public_key
  private_key
  visibility  Project::PRIVATE
end

Project.blueprint(:twitter_tagger) do
  name        "Twitter Tagger"
  public_key  "twitter_tagger"
  visibility  Project::PUBLIC
  owner       {User.make(:dora)}
end

Project.blueprint(:prideo) do
  name        "Private Video Application"
  public_key  "prideo"
  visibility  Project::PRIVATE
  owner       {User.make(:dora)}
end

Revision.blueprint do
  project_id {Project.make.id}
  commit_id {Commit.make.id}
end

Commit.blueprint do
  identifier      {Faker::Lorem.words(3).to_s}
  short_message   {Faker::Lorem.words(4).join(' ')}
  message         {Faker::Lorem.words(10).join(' ')}
  author_name     {Faker::Name.name}
  author_email    {Faker::Internet.email}
  committer_email {Faker::Internet.email}
  committer_name  {Faker::Name.name}
  committed_at    Time.now
  authored_at     30.minutes.ago
end

Payload.blueprint do
  project_id {Project.make.id}
  content "commits" => []
end

Plan.blueprint do
  name {Sham.title}
  visibility "public"
end

Plan.blueprint(:basic) do
  name "Basic"
  visibility "public"
end

Plan.blueprint(:custom) do
  name "Custom"
  visibility "private"
end

RevisionBridge.blueprint do
  parent_id {Commit.make.id}
  child_id  {Commit.make.id}
end

Subscription.blueprint do
  plan {Plan.make(:basic)}
end

Subscription.blueprint(:doras) do
  user {User.make(:dora)}
end
