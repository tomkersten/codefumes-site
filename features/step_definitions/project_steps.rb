Given /^no projects exist$/ do
  Project.destroy_all
end

Then /^he should see instructions for how to reserve that URI$/ do
  response.should have_tag(".instructions")
end


Given /^the "(.*)" project has been created$/ do |public_key|
  @project = Project.make(public_key.to_sym)
  raise "Project not created correctly (public_key: #{@project.public_key}" unless @project.public_key == public_key.to_s
end

Given /^the project has (\d+) commits$/ do |count|
  raise "@project must be set" unless @project.is_a?(Project)
  count.to_i.times {Revision.make(:project_id => @project.id)}
  raise "Commits not created correctly" unless @project.commits.count == count.to_i
end

Then /^(?:he|she|Sam|Dora|Oscar) should see its list of commits with (\d+) items in it$/ do |commit_count|
  response.should have_tag("ul.commits")
  response.should have_tag("ul.commits") do
    with_tag("li", :count => commit_count.to_i)
  end
end
