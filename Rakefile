# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'rom/sql/rake_task'
require 'pg'

Rails.application.load_tasks

namespace :db do
  task :setup do
    db_owner = Rails.application.secrets.db_owner
    db_name = Rails.application.secrets.db_name
    conn = PG.connect(dbname: db_name)
    conn.exec("CREATE DATABASE #{db_owner}")
  end
end
