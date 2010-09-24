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

require 'delayed_job'
require 'json'

module Junkfood
  module Ceb
    module Executors

      ##
      # The actual job class that is serialized for DelayedJob runs. which
      # is tasked to perform the commands.
      #
      # EXPERIMENTAL: This is untested, unfinished code.
      #
      class DelayedJobCommandExecutorJob < Struct(:message)

        ##
        # This method JSON parses the command data, instantiating the
        # referenced Command class, and finally executes the command.
        #
        def perform
          params = JSON.parse message
          command_class = params['_type'].constantize
          raise 'err' unless message_class.kind_of? ::Junkfood::Ceb::BaseCommand
          command = command_class.new params
          command.perform
        end
      end

      ##
      # An executor that queues up a DelayedJob to execute the command at
      # a later point in time.
      #
      # EXPERIMENTAL: This is untested, unfinished code.
      #
      class DelayedJobExecutor 

        ##
        # @param command (BaseCommand) the command to queue up.
        #
        def call(command)
          Delayed::Job.enqueue DelayedJobExecutorJob.new(command.to_json)
        end
      end
    end
  end
end
