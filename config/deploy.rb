set :application, "scm"

server "siamsoft.dyndns.org", :app, :web, :db, :primary => true
ssh_options[:keys] = ["/home/fernando/.ssh/id_rsa"]

set :repository,  "svn://siamsoft.dyndns.org/home/svn/repo/scm/trunk"
set :deploy_to, "/var/www/#{application}"
set :rails_env, "production"
