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
    # A Rack Application and Middleware that will execute a list
    # of callables in order until it receives a response without the
    # 'X-Cascade' header value set to 'pass'. ChainedRouter will then return
    # the response of said execution. The response of the last callable will
    # be returned if it is executed even if it has the 'X-Cascade' header set.
    # As Middleware, the given app will be the last callable in the chain.
    #
    # Example as Middleware:
    #
    #   use Junkfood::Rack::ChainedRouter do |router|
    #     router.add_route Proc.new { |env|
    #       # This proc is called, but it returns a pass.
    #       [404, { 'X-Cascade' => 'pass' }, []]
    #     }
    #     router.add_route Proc.new { |env|
    #       # This proc is called, but it also returns a pass.
    #       [404, { 'X-Cascade' => 'pass' }, []]
    #     }
    #   end
    #   run Proc.new { |env|
    #     # The main app is the last callable in ChainRouter's list.
    #     # And this will be executed.
    #     [200, { 'Content-Type' => 'text/plain' }, ['Hello World']]
    #   }
    #
    # Example as Middleware, without block parameter:
    #
    #   use Junkfood::Rack::ChainedRouter do
    #     add_route Proc.new { |env|
    #       # This proc is called, but it returns a pass.
    #       [404, { 'X-Cascade' => 'pass' }, []]
    #     }
    #     add_route Proc.new { |env|
    #       # This proc is called, but it also returns a pass.
    #       [404, { 'X-Cascade' => 'pass' }, []]
    #     }
    #   end
    #   run Proc.new { |env|
    #     # The main app is the last callable in ChainRouter's list.
    #     # And this will be executed.
    #     [200, { 'Content-Type' => 'text/plain' }, ['Hello World']]
    #   }
    #
    # Example as Application:
    #
    #   run Junkfood::Rack::ChainedRouter.new do |router|
    #     router.add_route Proc.new { |env|
    #       # This proc is called, but it returns a pass.
    #       [404, { 'X-Cascade' => 'pass' }, []]
    #     }
    #     router.add_route Proc.new { |env|
    #       # This is the last app to run.
    #       [200, { 'Content-Type' => 'text/plain' }, ['Hello World']]
    #     }
    #     router.add_route Proc.new { |env|
    #       # So this proc is never called.
    #       [200, { 'Content-Type' => 'text/plain' }, ['Never Run']]
    #     }
    #   end
    #
    class ChainedRouter

      ##
      # HTTP Not Found status code.
      HTTP_NOT_FOUND = 404.freeze

      ##
      # Header to set the content type value in the response.
      CONTENT_TYPE = 'Content-Type'.freeze

      ##
      # Header location where to look for the pass value.
      X_CASCADE = 'X-Cascade'.freeze

      ##
      # The pass string to signify triggering the next callable in the list.
      PASS = 'pass'.freeze

      ##
      # @param app the rack application. This will be last callable in chain.
      # @yield [router] block to configure the ChainedRouter if
      #   block arity greater than 0.
      # @yieldparam router newly instantiated ChainedRouter
      #
      def initialize(app=nil, &block)
        @chain = []
        if block_given?
          if block.arity == 0
            instance_eval &block
          else
            yield self
          end
        end
        @chain << app if app.respond_to? :call

        # Just validate the arguments
        @chain.each do |link|
          raise ArgumentError unless link.respond_to? :call
        end
      end

      ##
      # @param the rack request environment.
      #
      def call(env)
        # Set some defaults if the route set is empty.
        results = [
          HTTP_NOT_FOUND,
          {
            X_CASCADE => PASS,
            CONTENT_TYPE => 'text/plain'
          },
          []]
        # Call each link in chain.
        for link in @chain
          results = link.call env
          return results unless results[1][X_CASCADE] == PASS
        end
        # Return the results of the last link in chain, or the originally
        # set results if chain is empty.
        return results
      end

      ##
      # Appends a callable to the end of the call chain.
      #
      # @param app the callable to append.
      #
      def add_route(app)
        @chain << app
      end
    end
  end
end
