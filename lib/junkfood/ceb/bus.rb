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

require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'junkfood/ceb/executors/command_executor'
require 'junkfood/ceb/executors/event_executor'

module Junkfood
  module Ceb

    ##
    # Module to implement the bus framework for Ceb.
    #
    # @example
    #
    #   class WidgetCreateCommand < Junkfood::Ceb::BaseCommand
    #     def perform
    #       # Do Stuff.
    #     end
    #   end
    #
    #   class ApplicationController < ActionController::Base
    #     include Junkfood::Ceb::Bus
    #     acts_as_command_bus
    #   end
    #
    #   class WidgetController < ApplicationController
    #     def create
    #       # params['widget'] is our posted form data the same as how Rails
    #       # does it for ActiveModel. This eliminates hassle for
    #       # custom parsing, data handling.
    #
    #       # Create a command (WidgetCreateCommand) and puts it onto the bus
    #       # for execution. The command created is returned along with
    #       # published events by the command.
    #       command, events = send_command 'widget_create', params['widget']
    #
    #       if command.valid?
    #         # The command is correctly formed, so the backend executors will
    #         # execute it in the future (or already has executed it).
    #       end
    #
    #       # Commands SHOULD return the Event, or list of Events,
    #       # that the command published when its `perform` method was called.
    #       case result
    #       when Junkfood::Ceb::BaseEvent
    #         # The single published event.
    #         # Can assume that the command was executed.
    #       when Array
    #         # An array of Events published.
    #         # Can assume that the command was executed.
    #       when nil, false
    #         # No data was passed back. Nothing can be assumed about the
    #         # execution of the command.
    #       end
    #     end
    #   end
    #
    # Notes for implementers:
    # * Executors MAY reraise all raised errors
    #   * This is for problems in the "process" of executing commands,
    #   * not actual errors in the command's execution itself.
    # * Messages SHOULD handle their errors, publishing Error Events
    #   when a command fails.
    # * Callers of this method SHOULD check the command to see if
    #   validation errors occurred.
    #
    # @see ClassMethods
    #
    module Bus
      extend ActiveSupport::Concern

      ##
      # Methods to add to the actual classes that include Junkfood::Ceb::Bus.
      #
      module ClassMethods

        ##
        # Creates:
        # * a class attribute for the bus executor.
        # * an instance method to put a message onto the bus.
        #
        # @param bus_type (Symbol) the name of the bus.
        # @param executor (#call) a handler for the bus' messages.
        #
        def acts_as_bus(bus_type, executor=nil)
          class_eval do
            # We create the class attributes (accessors) for this executor
            # so individual instances or subclasses can override this.
            # And it sets it to the given executor or an empty executor
            executor_name = "#{bus_type}_executor"
            class_attribute executor_name
            send "#{executor_name}=", (executor || Proc.new {})

            # Now we define a the bus method in the form of `send_<bus_type>`.
            # This is the main method that objects call to look up the
            # commands/events, instantiate them, and execute on them.
            # This method will return the created command/event along with
            # the executor's results.
            method_name = "send_#{bus_type}"
            define_method(method_name, lambda { |name, *args|
              klass = "#{name}_#{bus_type}".to_s.classify.constantize
              message = klass.new *args
              results = message.valid? ? send(executor_name).call(message) : nil
              return message, results
            })
          end
        end

        ##
        # Creates:
        # * command_executor class attributes.
        # * send_command instance method to put commands onto the bus.
        #
        # @param executor (#call) an actual executor to use instead of the
        #   default ::Junkfood::Ceb::Executors::CommandExecutor.
        #
        def acts_as_command_bus(
            executor=::Junkfood::Ceb::Executors::CommandExecutor.new)
          acts_as_bus :command, executor
        end

        ##
        # Creates:
        # * event_executor class attributes.
        # * send_event instance method to put events onto the bus.
        #
        # @param executor (#call) an actual executor to use instead of the
        #   default ::Junkfood::Ceb::Executors::EventExecutor.
        #
        def acts_as_event_bus(
            executor=::Junkfood::Ceb::Executors::EventExecutor.new)
          acts_as_bus :event, executor
        end
      end
    end
  end
end
