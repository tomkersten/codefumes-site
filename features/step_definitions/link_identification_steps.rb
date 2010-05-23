Then /^s?he follows the link to edit the project$/ do
  click_link("Edit Project")
end

When /^she acknowledges the new project reminder message$/ do
  click_link("acknowledge-visibility")
end
