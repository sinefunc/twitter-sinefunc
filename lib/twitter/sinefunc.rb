require File.expand_path('../../../vendor/validatable/lib/validatable', __FILE__)

require 'twitter'

module Twitter
  module Sinefunc
    autoload :Validatable,  'twitter/sinefunc/validatable'
    autoload :StatusUpdate, 'twitter/sinefunc/status_update'
    autoload :Gateway,      'twitter/sinefunc/gateway'
  end
end
