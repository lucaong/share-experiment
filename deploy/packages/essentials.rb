package :essentials do
  description 'Build tools'
  apt %w(build-essential curl) do
    pre :install, 'apt-get update'
  end
end
