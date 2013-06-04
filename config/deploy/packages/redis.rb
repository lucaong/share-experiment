package :redis do
  description 'Redis key-value store'
  requires :redis_core, :redis_autostart
end

package :redis_core do
  apt 'redis-server'

  verify do
    has_executable 'redis-server'
  end
end

package :redis_autostart do
  description "Redis: autostart on boot"

  runner '/usr/sbin/update-rc.d redis-server defaults'
end

