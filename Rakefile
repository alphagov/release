# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

ReleaseApp::Application.load_tasks

desc "Lint Ruby"
task lint: :environment do
  sh "bundle exec rubocop"
end

task default: %i[test lint]
