desc "Run db migrations, specs, and JS tests"
task :migr_and_test => %w(db:migrate db:test:prepare spec)
