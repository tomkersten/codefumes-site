{
  :basic => {
    :visibility => "public",
    :private_project_qty => 1
  },
  :developer => {
    :visibility => "public",
    :private_project_qty => 5
  },
  :consultant => {
    :visibility => "public",
    :private_project_qty => 15
  },
  :corporation => {
    :visibility => "public",
    :private_project_qty => 35
  }
}.each do |plan_name, plan_attributes|
  plan = Plan.find_or_create_by_name(:name => plan_name.to_s)
  plan.update_attributes(plan_attributes)
end


