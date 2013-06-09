package :ruby do
  description "RVM and Ruby programming language"
  requires :rvm, :ruby_version, opts
end

package :rvm do
  runner '\curl -L https://get.rvm.io | bash -s stable'

  verify do
    has_executable '~/.rvm/bin/rvm'
  end
end

package :ruby_version do
  runner "~/.rvm/bin/rvm install #{opts[:ruby_version]}"

  verify do
    has_executable "~/.rvm/rubies/ruby-#{opts[:ruby_version]}/bin/ruby"
  end
end
