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
