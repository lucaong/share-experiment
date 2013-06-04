# Capistrano options for Vagrant (development stage)
set :user, "vagrant"
set :run_method, :sudo

role :app, "192.168.33.10"

ssh_options[:keys] = `vagrant ssh-config | grep IdentityFile | awk '{print $2}'`.chomp.gsub('"', "")
