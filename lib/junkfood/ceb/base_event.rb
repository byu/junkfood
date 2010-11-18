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

require 'date'
require 'mongoid'

module Junkfood
  module Ceb

    ##
    # The base class from which other classes derive Event modeling.
    # This is a mongoid document model with the following fields:
    # * _id - The mongodb id of the created Event.
    # * _type - The type of the event. Based off subclass Name.
    # * created_at - When the event was created/saved to mongodb.
    # * command_id - The command id to which this event was created in response.
    #
    # Example:
    #
    #   class PostCreatedEvent < Junkfood::Ceb::BaseEvent
    #     field :post_id, :type => Integer
    #     field :post_title, :type => String
    #     field :post_date, :type => DateTime
    #     field :post_body, :type => String
    #     field :post_author, :type => String
    #   end
    #
    # Events are meant to state a fact that something occured, and also
    # the relevant details of that event. In this case, we include all the
    # details of the Post created.
    #
    class BaseEvent
      include Mongoid::Document

      field :created_at, :type => DateTime

      referenced_in :command, :class_name => 'Junkfood::Ceb::BaseCommand'

      after_initialize :generate_default_values

      protected

      def generate_default_values
        self.created_at = DateTime.now unless self.created_at
      end
    end
  end
end
