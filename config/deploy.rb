set :stage, :production
set :application, 'jeremydwayne' 
set :copy_compression, :gzip
set :repo_url, 'git@github.com:jeremydwayne/jekyllblogtest.git'
set :scm, :git
set :deploy_via, :remote_cache
set :branch, "master"

set :user, "deploy"
set :ssh_options, { forward_agent: true }
set :use_sudo, false
set :pty, true
set :deploy_to, "/var/www/jeremydwayne"

namespace :deploy do
  [:start, :stop, :restart, :finalize_update].each do |t|
    desc "#{t} task is a no-op with jekyll"
    task t do 
      on primary roles :app do ; end
    end
  end

	desc "Make sure local git is in sync with remote."
	task :check_revision do
		on roles(:app) do
			unless `git rev-parse HEAD` == `git rev-parse origin/master`
				puts "WARNING: HEAD is not the same as origin/master"
				puts "Run `git push` to sync changes."
				exit
			end
		end
	end

  desc "Rebuild Jekyll before deploying"
  task :update_jekkyll do
    %x(rm -rf _site/* && jekyll build && rm _site/Capfile && rm -rf _site/config)
  end

  desc "Create Symlinks"
  task :create_symlinks do
    run "ln -s /var/www/#{:application}/current /var/www/#{:application}/releases"
  end

  desc "Fix Permissions"
  task :fix_permissions do
    run "chmod 775 -R #{current_path}"
  end

	before :starting,     :check_revision
  before :starting,     :update_jekkyll
	after  :finishing,    :cleanup
  after  :finishing,    :create_symlinks
  after  :finishing,    :fix_permissions

end
