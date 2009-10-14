Then /^s?he should see her current plan$/ do
  response.should have_tag("#current_plan")
end

Then /^s?he should see that the visualizations are disabled$/ do
  response.should have_tag("#upgrade_required")
end
