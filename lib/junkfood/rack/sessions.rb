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

module Junkfood
  module Rack

    ##
    # Rack Middleware that sets the 'rack.session' environment variable
    # with a new Hash object.
    #
    # This is specifically useful for when an application, or other middleware,
    # assumes that a rack session is set yet the developer doesn't want
    # to save an actual Cookie or Database session.
    #
    # For example, one may want to use API tokens for authentication
    # in a rack application protected by `warden`. Each request requires
    # the API token for each call and we don't want the authenticated user
    # to be saved in a Cookie session.
    #
    # Simply:
    #
    #   use Junkfood::Rack::TransientSession
    #   use Warden::Manager do |manager|
    #     manager.default_strategies :web_api_access_token
    #     manager.failure_app = Junkfood::WebApi::UnauthenticatedHandler.new
    #   end
    #   use Junkfood::WebApi::AccessTokenAuthentication
    #
    class TransientSession

      ##
      # @param app the rest of the Rack stack.
      #
      def initialize(app)
        @app = app
      end

      ##
      # @param env the Rack environment.
      # @return a Rack response from the application.
      #
      def call(env)
        env['rack.session'] = {}
        @app.call(env)
      end
    end
  end
end
