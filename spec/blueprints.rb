Sham.define do
  title       {Faker::Lorem.words(4).join(' ')}
  body        {Faker::Lorem.paragraphs(3).join('\n\n')}
  email       {Faker::Internet.email}
  user_name   {Faker::Internet.user_name}
  name        {Faker::Name.name}
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
  private_key
  visibility   Project::PUBLIC
end

Project.blueprint(:public) do
end

Project.blueprint(:private) do
  name        {Faker::Lorem.words(2).join(' ')}
  private_key
  visibility  Project::PRIVATE
end

Project.blueprint(:twitter_tagger) do
  name        "twitter_tagger"
  visibility  Project::PUBLIC
  owner       {User.find_by_login("dora.developer") || User.make(:dora)}
end

Project.blueprint(:prideo) do
  name        "prideo"
  visibility  Project::PRIVATE
  owner       {User.find_by_login("dora.developer") || User.make(:dora)}
end

Project.blueprint(:open_source) do
  name        "open_source"
  visibility  Project::PUBLIC
  owner       {User.find_by_login("oscar.opensource") || User.make(:oscar)}
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
  project_id {Project.make.id}
end

Payload.blueprint do
  project_id {Project.make.id}
  content "commits" => []
end

Plan.blueprint do
  name {Sham.title}
  visibility "public"
  private_project_qty 1
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

Subscription.blueprint(:confirmed) do
  plan {Plan.make(:basic)}
  state "confirmed"
end

Subscription.blueprint(:doras) do
  user {User['dora.developer'] || User.make(:dora)}
  state "confirmed"
end

Build.blueprint do
  commit_id  {Commit.make.id}
  name       {Sham.name}
  started_at {Time.now - 2.minutes}
  ended_at   {Time.now}
  state      "running"
end

Build.blueprint(:failed) {state "failed"}
Build.blueprint(:successful) {state "successful"}
Build.blueprint(:running) {}
