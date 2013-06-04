package :ruby do
  description "RVM and Ruby programming language"
  requires :rvm, :default_ruby
end

package :rvm do
  runner 'curl -L https://get.rvm.io | bash -s stable'

  verify do
    has_executable '~/.rvm/bin/rvm'
  end
end

package :default_ruby do
  runner '~/.rvm/bin/rvm install 2.0.0-p0'
  runner '~/.rvm/bin/rvm use --default 2.0.0-p0'

  verify do
    has_executable '~/.rvm/rubies/ruby-2.0.0-p0/bin/ruby'
  end
end