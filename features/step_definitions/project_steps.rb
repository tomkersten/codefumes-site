####################################
# Setup steps
####################################
Given /^no projects exist$/ do
  Project.destroy_all
end

Given /^the "(.*)" project has been created$/ do |name|
  @project = Project.make(name.to_sym)
  raise "Project not created correctly (public_key: #{@project.public_key}" unless @project.name == name.to_s
end

Given /^a public project has been created$/ do
  @project = Project.make(:public)
end

Given /^the project has (\d+) commits$/ do |count|
  raise "@project must be set" unless @project.is_a?(Project)
  commits = count.to_i.times.map {Commit.make(:project => @project)}

  commits.each_with_index do |commit, index|
    next unless commits[index.succ]
    RevisionBridge.make(:parent => commit, :child => commits[index.succ])
  end

  raise "Commits not created correctly" unless @project.commits.count == count.to_i
end

Given /^(?:he|she|Sam|Dora|Oscar) has claimed the following projects:$/ do |table|
  projects = table.hashes.each {|params_hash| Project.make(params_hash.merge(:owner_id => @user.id))}
end

####################################
# Assertion steps
####################################
Then /^(?:he|she|Sam|Dora|Oscar) sees? a list of commits with (\d+) items in it$/ do |commit_count|
  response.should have_tag("ul.commits")
  response.should have_tag("ul.commits") do
    with_tag("li", :count => commit_count.to_i)
  end
end

Then /^he should see a list of his claimed projects$/ do
  response.should have_tag("ul.projects")
end

Then /^s?he sees the private key of the project$/ do
  response.should have_tag("#project_keys")
end

Then /^s?he does not see the private key of the project$/ do
  response.should_not have_tag("#private_key")
end

Then /^he should not see the "new_subscription" link$/ do
  response.should_not have_tag("a#new_subscription")
end

Then /^he should see the "new_subscription" link$/ do
  response.should have_tag("a#new_subscription")
end

Then /^he should see a private project message$/ do
  response.should have_tag(".access_denied")
end
