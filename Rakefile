# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'rom/sql/rake_task'
require 'pg'

Rails.application.load_tasks

namespace :db do
  task :create do
    if Rails.env.production?
      puts 'Database is already created for production'
    else
      db_owner = Rails.application.secrets.db_owner
      db_name = Rails.application.secrets.db_name
      conn = PG.connect(dbname: db_owner)
      begin
        conn.exec_params("CREATE DATABASE #{db_name}")
      rescue PG::DuplicateDatabase
        puts "Database #{db_name} already exists"
      end
    end
  end
end
