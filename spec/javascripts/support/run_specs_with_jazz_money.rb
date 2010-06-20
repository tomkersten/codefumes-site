require 'rubygems'
require 'jazz_money'

javascript_files = [
  'public/javascripts/frameworks/jquery.js',
  'public/javascripts/frameworks/jquery.dates.js',
  'public/javascripts/frameworks/raphael.js',
  'public/javascripts/monkey_patches.js',
  'public/javascripts/visualizations/commits_over_time/commits_over_time.js',
  'public/javascripts/visualizations/commits_over_time/grid.js',
  'public/javascripts/visualizations/commits_over_time/svgmodal.js',
  'public/javascripts/visualizations/linegraph.js',
  'public/javascripts/visualizations/visualization_error.js'
]

jasmine_spec_files = [
  'spec/javascripts/monkey_patches_spec.js',
  'spec/javascripts/linegraph_spec.js',
  'spec/javascripts/commits_over_time_spec.js',
  'spec/javascripts/grid_spec.js',
  'spec/javascripts/svgmodal_spec.js',
  'spec/javascripts/visualization_error_spec.js'
]

JazzMoney::Runner.new(javascript_files, jasmine_spec_files).call