location = '134.209.251.52'

role :app, location
role :web, location
role :db,  location

server location, user: 'deploy', roles: %w[web app db], prymary: true

set :ssh_options, user: 'deploy', port: 5030
