package :postgres, :provides => :database do
  description 'PostgreSQL Database'
  requires :postgres_core, :postgres_autostart
end

package :postgres_core do
  apt 'postgresql'

  verify do
    has_executable 'psql'
  end
end

package :postgres_autostart do
  description "PostgreSQL: autostart on boot"
  
  runner '/usr/sbin/update-rc.d postgresql defaults'
end
