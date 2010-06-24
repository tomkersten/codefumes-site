javascript_frameworks = ["frameworks/jquery", "frameworks/jquery.dates", "frameworks/raphael", "frameworks/less", "monkey_patches"]
javascript_visualizations = ["visualizations/visualization_error", "visualizations/linegraph", "visualizations/commits_over_time/commits_over_time", "visualizations/commits_over_time/grid", "visualizations/commits_over_time/svgmodal"]
javascript_interface = ["expand_collapse", "initializer"]
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :frameworks => javascript_frameworks
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :visualizations => javascript_visualizations
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :interface => javascript_interface