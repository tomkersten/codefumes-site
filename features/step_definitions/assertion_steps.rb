Then /^s?he should see her current plan$/ do
  response.should have_tag("#current_plan")
end

Then /^s?he should see that the visualizations are disabled$/ do
  response.should have_tag("#upgrade_required")
end

Then /^she sees a new project reminder message$/ do
  response.should have_tag(".new-project-reminder")
end

Then /^she does not see a new project reminder message$/ do
  response.should_not have_tag(".new-project-reminder")
end
