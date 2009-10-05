When /^he fills out and submits in the subscription form, selecting the (\w+) plan$/ do |plan_type|
  # fill in form elements when we know wtf they are
  click_button("Review purchase")
end

Then /^he should see a confirmation form$/ do
  response.should have_tag("form.confirmation")
end

When /^he confirms the information$/ do
  click_button("confirmed")
end
