# config valid only for current version of Capistrano
lock '3.17.3'

set :application, 'cablook'
set :repo_url, 'git@github.com:galulex/cablook.git'

set :deploy_to, '/home/deploy/'

set :linked_files, fetch(:linked_files, []).push(
  'config/secrets.yml',
  'config/database.yml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system'
)

desc 'Deploy driver app'
namespace :driver do
  task :deploy do
    on roles(:all) do
      execute ' cd ~/current/driver && npm install && npm run build'
    end
  end
end
