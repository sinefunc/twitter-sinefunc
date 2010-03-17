$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fakeweb'
require 'twitter/sinefunc'
require 'rspec'

require File.join(File.dirname(__FILE__), '..', 'vendor', 'rspec-rails-matchers', 'lib', 'rspec-rails-matchers')

unless defined?(ActiveRecord)
  module ActiveRecord
    class Base; end
  end
end

Rspec.configure do |config|
end
