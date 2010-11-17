# encoding: utf-8
# Copyright 2010 Benjamin Yu <http://benjaminyu.org/>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'json'

module Junkfood
  module Rack

    ##
    # Rack Middleware to catch exceptions, then transform the exceptions
    # into serialized JSON objects to be returned to the caller.
    #
    # If this middleware catches an Exception, a rack request would be
    # returned with an HTTP status code, a json mime-type in the headers,
    # and JSON string as the response body.
    #
    # The HTTP status code will be 500 by default.
    #
    # The JSON object returned would have 'type', 'code' and 'message'
    # fields.
    # * 'type' will always be 'Error'.
    # * 'code' will be the class name of the caught exception, or
    #   a customized value.
    # * 'message' will be the message attribute of the caught exception, or
    #   a specifically set customized message.
    #
    # The developer can customize the HTTP status code, error code and
    # error message via the constructor. Individually, or all at once.
    #
    # For example:
    #   error_map = {
    #     'UnauthorizedException' => {
    #       'status_code' => 401,
    #       'code' => 'Unauthorized',
    #       'message' => 'The request did not have the required authorization'
    #     }
    #   }
    #   use Junkfood::Rack::ErrorHandler, error_map
    #
    # When the 'UnauthorizedException' error is caught, the middleware
    # will return a rack response with a 401 HTTP status code, a code with
    # 'Unauthorized', and the given custom error message.
    #
    class ErrorHandler
      ##
      # The default HTTP status code for caught errors.
      DEFAULT_STATUS_CODE = 500.freeze

      ##
      # Header to set the content type of error response
      CONTENT_TYPE = 'Content-Type'.freeze

      ##
      # Json's content type value for the content type header.
      JSON_CONTENT_TYPE = 'application/json'.freeze

      ##
      # @param app the rest of the rack stack
      # @param mapping the mapping of Exceptions to Error codes and messages.
      #
      def initialize(app, mapping={})
        @app = app
        @mapping = mapping
      end

      ##
      # @param env the rack environment.
      # @return a received rack response, or a generated JSON error
      #   in the response body with a custom status code.
      #
      def call(env)
        return @app.call(env)
      rescue Exception => e
        map = @mapping[e.class.name] || {}
        error = {
          'type' => 'Error',
          'code' => map['code'] || e.class.name,
          'message' => map['message'] || e.message
        }
        
        return [
          map['status_code'] ? map['status_code'].to_i : DEFAULT_STATUS_CODE,
          { CONTENT_TYPE => JSON_CONTENT_TYPE },
          [error.to_json]]
      end
    end
  end
end
