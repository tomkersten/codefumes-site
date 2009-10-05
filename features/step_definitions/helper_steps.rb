Then /^dump response$/ do
  puts response.body
end

Then /^(?:he|she) should see an error(?:\smessage)?$/ do
  response.should have_tag("#site_notifications .error")
end

Then /^(?:he|she) should see a notification(?:\smessage)?$/ do
  response.should have_tag("#site_notifications .notice")
end
