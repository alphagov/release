#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'ci/reporter/rake/minitest' if Rails.env.test?

ReleaseApp::Application.load_tasks

task :default => [:test, :check_for_bad_time_handling]
