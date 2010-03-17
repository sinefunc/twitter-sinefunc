module Twitter
  module Sinefunc
    class Gateway
      class Unauthorized < StandardError; end
      class Error < StandardError; end

      class << self
        attr_accessor :consumer_key, :secret
      end

      def initialize( options = {} )
        unless options[:token] or options[:secret]
          raise ArgumentError, "token and secret are both required"
        end

        @token, @secret = options.values_at(:token, :secret)
      end
  
      def get(path,    *args)   request(:get,    path, *args) end 
      def post(path,   *args)   request(:post,   path, *args) end 
      def put(path,    *args)   request(:put,    path, *args) end 
      def delete(path, *args)   request(:delete, path, *args) end 
      def head(path,   *args)   request(:head,   path, *args) end 
  
      private
        def request( verb, path, *args )
          response = interface.send( verb, append_extension(path), *args )
          handle response
        end
  
        def handle( response )
          case response
          when Net::HTTPOK
            begin
              JSON.parse( response.body ) 
            rescue JSON::ParserError
              response.body
            end

          when Net::HTTPUnauthorized
            raise Unauthorized, "The credentials did not authorized the user"

          else
            message = 
              begin
                JSON.parse(response.body)['error']
              rescue JSON::ParserError
                if match = response.body.match(/<error>(.*)<\/error>/)
                  match[1]
                else
                  'An error occurred processing your Twitter request.'
                end
              end

            raise Error, message
          end
        end

        def interface
          @interface ||= begin
            oauth = Twitter::OAuth.new(self.class.consumer_key, self.class.secret)
            oauth.authorize_from_access(@token, @secret)

            Twitter::Base.new(oauth)
          end
        end

        def append_extension(fullpath, extension = '.json')
          path, query_string = fullpath.split('?')
          path << extension if File.extname(path).empty?

          [ path, query_string ].compact.join('?')
        end
    end
  end
end
