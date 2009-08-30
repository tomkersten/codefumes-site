desc "Generate and send up metrics from metric_fu"
task :generate_and_ship_metrics do
  Rake::Task["metrics:all"].invoke
  Rake::Task["cf:metric_fu:coverage"].invoke
  Rake::Task["cf:metric_fu:loc_lot_stats"].invoke
end
