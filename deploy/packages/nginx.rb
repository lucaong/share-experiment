package :nginx, :provides => :webserver do
  description 'Nginx Web Server'
  requires :nginx_core, :nginx_autostart
end

package :nginx_core do
  apt 'nginx'

  verify do
    has_executable '/etc/init.d/nginx'
  end
end

package :nginx_autostart do
  description "Nginx: autostart on boot"

  runner '/usr/sbin/update-rc.d nginx defaults'
end
