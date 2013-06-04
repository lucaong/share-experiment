package :git, :provides => :version_control do
  description 'Git version control'

  apt 'git'

  verify do
    has_executable 'git'
  end
end
