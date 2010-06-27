When /^s?he fills out and submits in the subscription form, selecting the (\w+) plan$/ do |plan_type|
  # fill in form elements when we know wtf they are
  choose(plan_type)
  click_button("Review purchase")
end

Then /^s?he should see a confirmation form$/ do
  response.should have_tag("form.confirmation")
end

When /^s?he confirms the information$/ do
  click_button("confirmed")
end

When /^s?he submits the form$/ do
  click_button
end
