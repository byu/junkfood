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

require 'junkfood/ceb/bus'
require 'mongoid'

module Junkfood
  module Ceb

    ##
    # BaseCommand abstract class from which one defines and implements
    # actual Commands to be run.
    #
    # _id (id)
    # _type
    # created_at
    # origin
    class BaseCommand
      include Junkfood::Ceb::Bus
      include Mongoid::Document

      acts_as_event_bus

      references_many(
        :events,
        :inverse_of => :command,
        :class_name => 'Junkfood::Ceb::BaseEvent')

      field :created_at, :type => Time
      field :origin, :type => String

      after_initialize :generate_default_values

      ##
      # @abstract implement the actual handler logic to execute the command.
      #
      def perform
      end

      protected

      ##
      # Before create hook to set the Command's default values.
      #
      def generate_default_values
        self.created_at = Time.now unless self.created_at
      end
    end
  end
end
