Then /^s?he follows the link to edit the project$/ do
  click_link("Edit Project")
end

When /^she acknowledges the new project reminder message$/ do
  click_link("acknowledge-visibility")
end

When /^she follows the link to view temperature_attribute$/ do
  click_link("temperature_attribute")
end

