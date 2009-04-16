Then /^dump response$/ do
  puts response.body
end

Then /^I should see an error message$/ do
  response.should have_tag("#site_notifications .error")
end

Then /^I should see a notification$/ do
  response.should have_tag("#site_notifications .notice")
end
