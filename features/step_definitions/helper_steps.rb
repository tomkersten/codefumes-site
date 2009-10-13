Then /^dump response$/ do
  puts response.body
end

Then /^(?:he|she) should see an error(?:\smessage)?$/ do
  response.should have_tag("#site_notifications .error")
end

Then /^(?:he|she) should see a notification(?:\smessage)?$/ do
  response.should have_tag("#site_notifications .notice")
end

When /she visits the "(\w+)" project page$/ do |project_public_key|
  @project = Project.find_by_public_key(project_public_key)
  raise "No project found with #{project_public_key}" if @project.nil?
  visit short_uri_path(@project)
end
