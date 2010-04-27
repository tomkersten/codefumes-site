Then /^dump response$/ do
  puts response.body
end

Then /^(?:he|she) should see an error(?:\smessage)?$/ do
  response.should have_tag("#site_notifications .error")
end

Then /^(?:he|she) should see a notification(?:\smessage)?$/ do
  response.should have_tag("#site_notifications .notice")
end

When /she visits the "(\w+)" project page$/ do |project_name|
  @project = Project.find_by_name(project_name)
  raise "No project found with #{project_name}" if @project.nil?
  visit short_uri_path(@project)
end

When /^s?he follows the link to edit the  project$/ do
  click_link(".edit.project")
end
