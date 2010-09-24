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
  module Ceb
    module Executors

      ##
      # Processes the event from the event_bus. The event is saved.
      # TODO: emit json serialized event to other listeners.
      #
      class EventExecutor

        ##
        # @param event (BaseEvent) the event to save and perform.
        #
        def call(event)
          event.save! if event.new_record?
        end
      end
    end
  end
end
