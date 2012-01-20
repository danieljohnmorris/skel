# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

App::Application.load_tasks

# If a Spork task is called, don't load the Rails environment
# but instantly import and start the task. (Fast)
if Rake.application.top_level_tasks.first =~ /^spork/
  import File.expand_path("../lib/tasks/spork.rake", __FILE__)
else
  # Load the Rails environment and load all tasks. (Slow)
  require File.expand_path("../config/application", __FILE__)
  App::Application.load_tasks
end