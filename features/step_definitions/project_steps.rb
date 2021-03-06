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

Given /^the project has (\d+) unique custom attributes$/ do |unique_attributes|
  commit = Commit.make(:project => @project)
  commit.custom_attributes.create!({ :name => 'temperature', :value => '72' })
  commit.custom_attributes.create!({ :name => 'chairs', :value => '3' })
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

Then /^(?:he|she|Sam|Dora|Oscar) sees? a list of custom attributes with (\d+) items in it$/ do |attribute_count|
  response.should have_tag("div.attributes")
  response.should have_tag("div.attributes") do
    with_tag("li.custom_attribute", :count => attribute_count.to_i)
  end
end

Then /^s?he should see a list of his claimed projects$/ do
  response.should have_tag("ul.projects")
end

Then /^s?he sees the private key of the project$/ do
  response.should have_tag("#project_keys")
end

Then /^s?he does not see the private key of the project$/ do
  response.should_not have_tag("#private_key")
end

Then /^s?he should not see the "new_subscription" link$/ do
  response.should_not have_tag("a#new_subscription")
end

Then /^s?he should see the "new_subscription" link$/ do
  response.should have_tag("a#new_subscription")
end

Then /^s?he should see a private project message$/ do
  response.should have_tag(".access_denied")
end

Then /^s?he sees temperature_attribute name selected$/ do
  response.should have_tag('#temperature_attribute.selected')
end

Then /^chairs_attribute should not be selected$/ do
  response.should have_tag('#chairs_attribute')
end

Then /^s?he sees a link about custom attributes$/ do
  response.should have_tag('a.intro_to_attributes')
end

Then /^s?he sees build status selected$/ do
  response.should have_tag('a#build_status.selected')
end

