package :nginx, :provides => :webserver do
  description 'Nginx Web Server'
  requires :nginx_core, :nginx_config, :nginx_autostart, opts
end

package :nginx_core do
  apt 'nginx'

  verify do
    has_executable '/etc/init.d/nginx'
  end
end

package :nginx_config do
  transfer File.expand_path('../files/nginx.conf', File.dirname(__FILE__)),
    '/etc/nginx/nginx.conf', :render => true, :sudo => true,
    :locals => opts
end

package :nginx_autostart do
  description "Nginx: autostart on boot"

  runner '/usr/sbin/update-rc.d nginx defaults'
end
