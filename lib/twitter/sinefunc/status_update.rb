module Twitter
  module Sinefunc
    module StatusUpdate
      def self.included( model )
        model.class_eval do
          include Twitter::Sinefunc::Validatable

          attr_accessor :sender
          attr_writer   :body

          validates_presence_of :body, :sender
          validates_length_of   :body, :within => 1..140

          extend ClassMethods
        end
      end

      module ClassMethods
        def validates_body_has_added_content( message = nil )
          validates_true_for :body, 
            message: message || "must have some content provided",
            logic:   lambda { to_s.strip != body.to_s.strip }
        end

        def body(str, interpolations = {})
          template( str )
          interpolations( interpolations )
        end

        def template( str = nil )
          @template = str if str
          @template
        end

        def interpolations( values = nil )
          @interpolations = values if values
          @interpolations
        end
      end

      def initialize( attrs = {} )
        attrs.each { |field, value| send("#{field}=", value) } 
      end
      
      def body
        defined?(@body) ? @body : to_s
      end

      def to_s
        format_string = 
          self.class.template.dup.tap do |tmpl|
            interpolations.each do |field, value|
              tmpl.gsub!( ":#{field}", value ) if value
            end
          end
        
        format_string % item.to_s
      end

      def respond_to?( method )
        interpolations.has_key?( method ) ? true : super
      end

      private
        def method_missing(meth, *args, &blk)
          if interpolations.has_key?(meth)
            interpolations[meth]
          else
            super
          end
        end

        def interpolations
          self.class.interpolations.inject({}) do |hash, (field, block)|
            hash[field] = instance_eval(&block) rescue nil
            hash
          end
        end
    end
  end
end

