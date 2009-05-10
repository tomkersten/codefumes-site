Given /^no projects exist$/ do
  Project.destroy_all
end

Then /^he should see instructions for how to reserve that URI$/ do
  response.should have_tag(".instructions")
end
