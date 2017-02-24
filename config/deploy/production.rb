set :stage, :production
server '45.76.23.120', user: 'deploy', roles: %w{web app db}
