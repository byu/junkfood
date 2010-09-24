Junkfood
========

Junkfood is a mesh of different modules and classes that I found useful
for various projects. I combined them all into this all-in-one library
because each included component isn't big enough (or comprehensive
enough) to warrant its own fully managed gem library.

Components
----------

* Adler32
* Assert
* Base32
* CEB - "Command-Event Busing" for Command-Query Responsibility Separation
* OneTime - HMAC One Time Passwords
* PaperclipStringIO
* Settings

Adler32
=======

[Adler-32](http://en.wikipedia.org/wiki/Adler-32) is a checksum algorithm
which was invented by Mark Adler. Compared to a cyclic redundancy check
of the same length, it trades reliability for speed. Adler-32 is more
reliable than Fletcher-16, and slightly less reliable than Fletcher-32.

Junkfood provides two implementations of Adler-32 in Ruby:

* Adler32 uses the Zlib library to do the checksum.
* Adler32Pure is a pure Ruby implementation of Adler-32 ported
  from the [Pysync library](http://freshmeat.net/projects/pysync/).

Example:

    adler32 = Junkfood::Adler32.new('Wikipedia') # Or Junkfood::Adler32Pure.new
    puts adler32.digest #=> 300286872

    adler32 = Junkfood::Adler32.new
    digest = adler32.update 'Wikipedia' #=> 300286872
    adler32.digest #=> 300286872

Assert
======

A very simple assertions module to be a drop in "dumb down" replacement
for the 'wrong' assertion library. It is here just to be my own fallback
implementation for cases where I may not actually want to install the
[wrong gem](<http://rubygems.org/gems/wrong>) yet still like that
style of assertions.

    require 'junkfood/assert'
    class MyClass
      include Junkfood::Assert

      def my_method
        testcase = true
        assert { testcase == true }  # This will flow through.
        assert { testcase == false } # This will raise an error.
        assert('My Custom Error Message') {
          testcase == false
        }
      rescue Junkfood::Assert::AssertionFailedError => e
        puts e
      end
    end

Base32
======

A ruby implementation of [RFC4648](http://http://tools.ietf.org/html/rfc4648).
This class requires at least version Ruby 1.9 because it uses the new
String Encodings internally.

    require 'junkfood/base32'

    # Base32 uses StringIO objects by default.
    io = Junkfood::Base32.encode 'MyBinaryStringData'
    puts io.string
    puts io.string.encoding #=> Encoding::ASCII

    io = Junkfood::Base32.decode 'MyBase32StringData'
    puts io.string
    puts io.string.encoding #=> Encoding::BINARY

    # The IO can be any object that conforms to Ruby IO.
    # The returned io is the same file passed to output.
    io = Junkfood::Base32.encode 'BinaryData', :output => open('out.b32', 'w')
    io = Junkfood::Base32.decode 'Base32Data', :output => open('out.bin', 'w')

    # Input is any object that conforms to #each_byte. This includes
    # Strings and File IOs.
    io = Junkfood::Base32.encode(
      open('in.bin', 'r'),
      :output => open('out.b32', 'w'))
    io.close
    io = Junkfood::Base32.decode(
      open('in.b32', 'r'),
      :output => open('out.bin', 'w'))
    io.close


Command Event Busing (CEB)
==========================

This component is meant to support Command-Query Responsibility Separation.

CEB is comprised of three major parts:

* The Base Models (BaseCommand, BaseEvent)
* The Bus (Bus)
* The Executors (CommandExecutor, EventExecutor)

The Base Models implement the foundation of Commands and Events in CQRS;
the Bus instantiates Command/Event from the parameters, validates
(using ActiveModel valid?) the Command/Event and drives its process with
the associated executors; executors (one per Command or Event bus) runs
the specific process to handle a command or event.

Commands are both data representation and handler code for its function.
Events are just statements of fact about changes in the system.

CEB Base Models
---------------

BaseCommand and BaseEvent uses MongoDb via [mongoid](http://mongoid.org/).
Command and Event models SHOULD implement the ActiveModel interface; they
must at least implement the subset of features as described by the
RSpec tests in base_command_spec.rb and base_event_spec.rb.

These base models:

1. Provide persistence for audit logs.
2. Provide the base help to represent Commands and Events in our framework.
  Users will subclass BaseCommand and BaseEvent to model their domain.
3. Be the "standard contract" for others that want to implement their
  base models. E.g. - Use ActiveRecord instead of Mongoid.

Subclasses of BaseCommand that implement their own `perform` method
SHOULD return the Event (or list of Events) published when said `perform`
method was executed.

CEB Executors
-------------

We implement helpers for the Command Bus and Event Bus part of CQRS.
So we have two default executors to handle the logic for those two buses.

* CommandExecutor
* EventExecutor

CommandExecutor is the default command bus executor that:

1. just calls save! on the instantiated command, raising errors on failure.
2. executes the command's perform method (with the assumption that
  the bus validated the command beforehand).
3. the return value from `perform` is passed back to the bus send_command
  or send_event call.

Alternative CommandExecutors (e.g. - for DelayedJob) may just use its
own mechanisms to queue up the Command (most likely using the Command's
to_json serialization) for later execution. In this case, the executor's
call should return nil or false to the bus. This return value is convention
to signal this delayed execution to the requester.

EventExecutor is the default event bus executor that:

1. just calls save! on the instantiated event, raising errors on failure.
2. TODO: publishes the serialized Event (to_json) over a PubSub network such
  as zeromq or webhooks.

CEB Example
-----------

    class WidgetCreateCommand < Junkfood::Ceb::BaseCommand

      field :color, :type => String, :default => 'red'

      def perform
        # Do creation. Update DDD aggregate root, or ActiveRecord State,
        # or whatever is used to keep application state.
        success = true

        # Now we publish events based on what happened.
        # Normally, there is a one-to-one relation between the number of
        # commands performed to the number of event published.
        if success
          event, result = send_event(
            'widget_created',
            :command_id => self.id,
            :color => color,
            :other_widget_info => 'to be determined')
        else
          event, result = send_event(
            'widget_creation_failed',
            :command_id => self.id,
            :error => 'some determined error',
            :other_widget_info => 'to be determined')
        end

        # This is convention. Commands SHOULD return the event, or list of
        # events, that it published in the execution of this perform method.
        return event
      end
    end

    class WidgetCreatedEvent < Junkfood::Ceb::BaseEvent
      field :color, :type => String
      field :other_widget_info, :type => String
    end

    class WidgetCreationFailedEvent < Junkfood::Ceb::BaseEvent
      field :error_info, :type => String
      field :other_widget_info, :type => String
    end

    class ApplicationController < ActionController::Base
      include Junkfood::Ceb::Bus
      acts_as_command_bus
    end

    class WidgetController < ApplicationController
      def create
        # params['widget'] is our posted form data that conforms to the Rails
        # way of doing things for ActiveModel. This eliminates hassle for
        # custom parsing, data handling.

        # Create a command (WidgetCreateCommand) and puts it onto the bus
        # for execution. The command created is returned along with
        # published events by the command.
        command, events = send_command 'widget_create', params['widget']

        if command.valid?
          # The command is correctly formed, so the backend executors will
          # execute it in the future (or already has executed it).
        end

        # By convention, Commands SHOULD return the Event, or list of Events,
        # that the command published when its `perform` method was called.
        case result
        when Junkfood::Ceb::BaseEvent
          # The single published event.
          # Can assume that the command was executed.
        when Array
          # An array of Events published.
          # Can assume that the command was executed.
        when nil, false
          # No data was passed back. Nothing can be assumed about the
          # execution of the command.
        end
      end
    end

OneTime - HMAC One Time Passwords
=================================

OneTime implements [RFC4226](http://tools.ietf.org/html/rfc4226) and the
[Time Based](http://tools.ietf.org/html/draft-mraihi-totp-timebased-06)
version.

View the OneTime class docs to see all the options for setting the
initial counter, time steps, and number of digits each OneTime instance.

Example:

    key = '12345678901234567890'

    # Using the class methods to get OTP one at a time.
    puts Junkfood::OneTime.hotp(key, 0) #=> 755224
    puts Junkfood::OneTime.hotp(key, 1) #=> 287082

    # Changing the length of the OTP
    puts Junkfood::OneTime.hotp(key, 0, :digits => 8) #=> 84755224

    # Using the class methods to get multiple OTP at a time.
    puts Junkfood::OneTime.hotp_multi(key, 0..1) #=> [755224, 287082]

    # Create a new OTP generator starting at counter 0.
    one_time = Junkfood::OneTime.new key
    # Get an OTP, but don't advance the counter
    puts one_time.otp #=> 755224
    puts one_time.otp #=> 755224
    # Get a range of OTP
    puts one_time.otp :range => 2 #=> [755224, 287082]

    # Get an OTP, and advance the counter
    puts one_time.otp! #=> 755224
    puts one_time.otp! #=> 287082
    puts one_time.counter #=> 2
    puts one_time.otp! :range => 2 #=> [359152, 969429]
    puts one_time.counter #=> 4

    # The current Time based OTP for the current epoch step.
    puts one_time.totp
    # A bunch of OTPs preceding and following the current epoch step OTP.
    puts one_time.totp :radius => 2

    # Setting the length and counter of the OTP on a OneTime instance
    one_time = Junkfood::OneTime.new key, :digits => 8, :counter => 2
    puts one_time.otp! #=> 37359152
    puts one_time.otp! #=> 26969429

PaperclipStringIO
=================

This class allows developers to save blobs of in-memory data into
[paperclip](http://rubygems.org/gems/paperclip) enabled ActiveRecord models
without requiring the use of temporary files.

Example:

    class FaxDocument < ActiveRecord::Base
      has_attached_file :pdf
    end

    def incoming_fax_handler()
      attachment = 'Blob of Faxed Data in PDF form'
      fax_number = '555-1234'

      fax_document = FaxDocument.create(
        :caption => 'Look at this Document!',
        :pdf => PaperclipStringIo.new(
          attachment,
          :filename => "#{fax_number}.pdf",
          :content_type => 'application/pdf'))
    end


Settings
========

A singleton to allow all parts of a Rails application use the same set
of settings, loaded from the same settings yaml file.

Testing
=======
This library uses [Bundler](http://gembundler.com/) for development and testing.

> bundle install
>
> rake spec
>
> rake rcov

Note on Patches/Pull Requests
=============================
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a
  commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Authors
=======
* Benjamin Yu - <http://benjaminyu.org/>, <http://github.com/byu>

Copyright
=========

> Copyright 2009-2010 Benjamin Yu
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
> http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.
