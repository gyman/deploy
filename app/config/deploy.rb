# configuration

set :app_path,    "app"
set :branch, "master"
set :application, "gyman"

set :shared_files,      ["app/config/parameters.yml"]
set :shared_children,     [app_path + "/logs", web_path + "/uploads", app_path + "/spool", app_path + "/sessions"]

disable_log_formatters
log_formatter(:color => :white, :priority => 120)

set :ssh_options, {
    :forward_agent => true,
    :auth_methods => ["publickey"],
}

set :use_composer, true
set :cache_warmup, true
set :composer_options,  "--verbose --prefer-dist --optimize-autoloader"
set :update_vendors, false
set :vendors_mode, "install"

set :scm,         :git

set :writable_dirs,       ["app/cache", "app/sessions", "app/logs", web_path + "/uploads"]
set :webserver_user,      "www-data"
set :permission_method,   :acl
set :use_set_permissions, true

set :model_manager, "doctrine"

# role :web,        domain                         # Your HTTP server, Apache/etc
# role :app,        domain, :primary => true       # This may be the same as your `Web` server

set :keep_releases,  3

set :use_sudo,  false

set :dump_assetic_assets, false
set :interactive_mode, false

# environments: production, test

task :production do
	set 	:user, "uirapuru"
	server 	'uirapu.ru', :app, :web, :primary => true

	set :branch, "master"
end

task :testing do
	set 	:user, "uirapuru"
	server 	'uirapu.ru', :app, :web, :primary => true

	set :branch, "develop"
end

# projects: application, webpage

task :application do
	set :deploy_to,   "/var/www/app.gyman.pl"
	set :repository,  "git@github.com:gyman/app.git"

	after "deploy:restart", "deploy:index"
	after "deploy:restart", "apache:restart"

	namespace :apache do
	    # Apache needs to be restarted to make sure that the APC cache is cleared.
	    desc "Restart Apache"
		task :restart, :except => { :no_release => true }, :roles => :app do
		    run "sudo /etc/init.d/apache2 restart"
		    puts "--> Apache successfully restarted".green
	    end
	end

	namespace :deploy do
	    desc "Copy app.php -> index.php"
		task :index, :except => { :no_release => true }, :roles => :app do
		    run "cp #{current_path}/web/app.php #{current_path}/web/index.php"
		    puts "--> Created index.php".green
	    end
	end
end

task :webpage do
	set :deploy_to,   ""
	set :repository,  "ssh://git@github.com:gyman/webpage.git"
end


# Be more verbose by uncommenting the following line

# logger.level = Logger::MAX_LEVEL

# Run migrations before warming the cache

after "deploy:restart", "deploy:cleanup"

