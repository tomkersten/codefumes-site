javascript_frameworks = ["frameworks/jquery", "frameworks/jquery.dates", "frameworks/raphael", "monkey_patches"]
javascript_visualizations = ["visualizations/linegraph", "visualizations/commits_over_time/commits_over_time", "visualizations/commits_over_time/grid", "visualizations/commits_over_time/svgmodal"]

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :frameworks => javascript_frameworks
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :visualizations => javascript_visualizations