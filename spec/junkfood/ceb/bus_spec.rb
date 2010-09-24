require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Ceb::Bus' do

  it 'should acts_as_bus' do
    class TestFoo
      def initialize(valid)
        @valid = valid
      end
      def valid?
        @valid
      end
    end

    # Test that we have the proper attributes and methods created with defaults.
    controller_class = Class.new do
      include Junkfood::Ceb::Bus
      acts_as_bus :foo
    end
    controller_instance = controller_class.new
    controller_instance.respond_to?(:send_foo).should be_true
    controller_instance.respond_to?(:foo_executor).should be_true
    controller_instance.respond_to?(:foo_executor=).should be_true
    controller_instance.foo_executor.should be_kind_of(Proc)

    # Now override the executor on the initialization
    my_executor = mock('MyExecutor')
    controller_class = Class.new do
      include Junkfood::Ceb::Bus
      acts_as_bus :foo, my_executor
    end
    controller_instance = controller_class.new
    controller_instance.respond_to?(:send_foo).should be_true
    controller_instance.respond_to?(:foo_executor).should be_true
    controller_instance.respond_to?(:foo_executor=).should be_true
    controller_instance.foo_executor.should eql(my_executor)

    # Now test that we can override the executor, and that the
    # bus creates and executes with an instane of the TestCommand
    executor1 = mock('FooExecutor')
    executor1.should_receive(:call).with(an_instance_of(TestFoo))
    controller_instance.foo_executor = executor1
    controller_instance.foo_executor.should eql(executor1)
    controller_instance.send_foo 'test', true

    # Now we make sure that the TestCommand is invalid, so the
    # executor will not be called.
    executor2 = mock('FooExecutor')
    controller_instance.foo_executor = executor2
    controller_instance.foo_executor.should eql(executor2)
    controller_instance.send_foo 'test', false
  end

  it 'should acts_as_command_bus' do
    class TestCommand
      def initialize(valid)
        @valid = valid
      end
      def valid?
        @valid
      end
    end

    # Test that we have the proper attributes and methods created
    controller_class = Class.new do
      include Junkfood::Ceb::Bus
      acts_as_command_bus
    end
    controller_instance = controller_class.new
    controller_instance.respond_to?(:send_command).should be_true
    controller_instance.respond_to?(:command_executor).should be_true
    controller_instance.respond_to?(:command_executor=).should be_true
    controller_instance.command_executor.should be_kind_of(
      Junkfood::Ceb::Executors::CommandExecutor)

    # Test again that we have the proper attributes and methods created
    my_executor = mock('MyExecutor')
    controller_class = Class.new do
      include Junkfood::Ceb::Bus
      acts_as_command_bus my_executor
    end
    controller_instance = controller_class.new
    controller_instance.respond_to?(:send_command).should be_true
    controller_instance.respond_to?(:command_executor).should be_true
    controller_instance.respond_to?(:command_executor=).should be_true
    controller_instance.command_executor.should eql(my_executor)

    # Now test that we can override the executor, and that the
    # bus creates and executes with an instane of the TestCommand
    executor1 = mock('CommandExecutor')
    executor1.should_receive(:call).with(an_instance_of(TestCommand))
    controller_instance.command_executor = executor1
    controller_instance.command_executor.should eql(executor1)
    controller_instance.send_command 'test', true

    # Now we make sure that the TestCommand is invalid, so the
    # executor will not be called.
    executor2 = mock('CommandExecutor')
    controller_instance.command_executor = executor2
    controller_instance.command_executor.should eql(executor2)
    controller_instance.send_command 'test', false
  end

  it 'should acts_as_event_bus' do
    class TestEvent
      def initialize(valid)
        @valid = valid
      end
      def valid?
        @valid
      end
    end

    # Test that we have the proper attributes and methods created
    controller_class = Class.new do
      include Junkfood::Ceb::Bus
      acts_as_event_bus
    end
    controller_instance = controller_class.new
    controller_instance.respond_to?(:send_event).should be_true
    controller_instance.respond_to?(:event_executor).should be_true
    controller_instance.respond_to?(:event_executor=).should be_true
    controller_instance.event_executor.should be_kind_of(
      Junkfood::Ceb::Executors::EventExecutor)

    # Test again that we have the proper attributes and methods created
    my_executor = mock('MyExecutor')
    controller_class = Class.new do
      include Junkfood::Ceb::Bus
      acts_as_event_bus my_executor
    end
    controller_instance = controller_class.new
    controller_instance.respond_to?(:send_event).should be_true
    controller_instance.respond_to?(:event_executor).should be_true
    controller_instance.respond_to?(:event_executor=).should be_true
    controller_instance.event_executor.should eql(my_executor)

    # Now test that we can override the executor, and that the
    # bus creates and executes with an instane of the TestEvent
    executor1 = mock('EventExecutor')
    executor1.should_receive(:call).with(an_instance_of(TestEvent))
    controller_instance.event_executor = executor1
    controller_instance.event_executor.should eql(executor1)
    controller_instance.send_event 'test', true

    # Now we make sure that the TestEvent is invalid, so the
    # executor will not be called.
    executor2 = mock('EventExecutor')
    controller_instance.event_executor = executor2
    controller_instance.event_executor.should eql(executor2)
    controller_instance.send_event 'test', false
  end
end
