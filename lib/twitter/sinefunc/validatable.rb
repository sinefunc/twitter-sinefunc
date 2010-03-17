module Twitter
  module Sinefunc
    module Validatable
      def self.included( model )
        model.send :include, ::Validatable
      end

      def invalid?
        !valid?
      end
    end
  end
end

class ::Validatable::Errors
  def []( field )
    Array( on(field) )
  end
end
