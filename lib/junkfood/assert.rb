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

  ##
  # A dumbed down implementation for Assertions based on the 'wrong' gem,
  # but without any of wrong's awesomeness. This is just for the future in
  # case 'wrong' disappears from the scene.
  #
  # @example
  #   class MyClass
  #     include Junkfood::Assert
  #     def my_method
  #       assert { true }
  #       assert('Custom Error Message') { false }
  #     rescue Junkfood::Assert::AssertionFailedError => e
  #       puts e
  #     end
  #   end
  #
  module Assert

    ##
    # Error thrown when an assertion fails.
    #
    class AssertionFailedError < RuntimeError
    end

    ##
    # Tests an assertion claim.
    #
    # @example
    #   x = 3
    #   assert { x == 2 }
    #   assert('failure message') { x == 1 }
    #
    # @overload assert
    #   @yield block with predicates to determine whether or not to raise
    #     an AssertionFailedError.
    #   @yieldreturn [Boolean, nil]
    #
    # @overload assert(message)
    #   @param message (String) the custom error message of for the
    #     AssertionFailedError.
    #   @yield block with predicates to determine whether or not to raise
    #     an AssertionFailedError.
    #   @yieldreturn [Boolean, nil]
    #
    # @raise AssertionFailedError when the block yields a false/nil value.
    #
    # @see http://rubygems.org/gems/wrong
    #
    def assert(*args, &block)
      begin
        return super if block.nil?
      rescue NoMethodError
        raise 'You must pass a block for assertion check'
      end
      raise AssertionFailedError, args.first unless yield
    end
  end
end
