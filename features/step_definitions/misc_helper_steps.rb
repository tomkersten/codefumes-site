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

Given /^the rest is undecided functionality$/ do
  pending "Then the remaining steps are skipped."
end

Given /^this scenario is disabled due to a bug with Rails 2.3.8 and Webrat 0.7.0/ do
  pending if Rails.version == "2.3.8" && Webrat::VERSION == "0.7.0"
end
