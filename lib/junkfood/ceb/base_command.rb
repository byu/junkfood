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
    # * _id - The mongodb id of the created Command.
    # * _type - The type of the command. Based off subclass Name.
    # * created_at - When the event was created/saved to mongodb.
    # * origin - A descriptive string about where this command originated.
    #   For example, from the main web application or a separate web service
    #   api.
    #
    # Example:
    #
    #   ##
    #   # This is a simple command that creates a blog post, which is backed
    #   # by an ActiveRecord based model.
    #   #
    #   class Post::CreateCommand < Junkfood::Ceb::BaseCommand
    #
    #     def perform
    #       # The constructor is set to be a Mongoid document constructor,
    #       # so all of the fields passed become dynamic attributes.
    #       # We access such attributes with the read_attribute method.
    #       #
    #       # The following example reads specific attributes to be passed
    #       # on to the actual Post model for creation.
    #       params = {
    #         'user_id' => read_attribute(:author_id),
    #         'title' => read_attribute(:title),
    #         'body' => read_attribute(:body),
    #       }
    #       post = Post.new(params)
    #       # The BaseCommand object is an event_bus, so we can
    #       # use it to send off events... then return the sent event.
    #       if post.save
    #         event, result = send_event :post_created, post
    #       else
    #         event, result = send_event :post_failed, post
    #       end
    #       return event
    #     end
    #   end
    #
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
