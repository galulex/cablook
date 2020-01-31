# config valid only for current version of Capistrano
lock '3.10.2'

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
      execute 'rm -rf ~/cablook && git clone git@github.com:galulex/cablook.git ~/cablook'
      execute ' cd ~/cablook/driver && npm install && npm run build'
      execute ' cd ~/current/public && rm -rf build && ln -s ~/cablook/driver/public/build build'
      execute ' cd ~/current/public && rm driver.html && ln -s ~/cablook/driver/public/index.html driver.html'
    end
  end
end
