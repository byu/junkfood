require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'Ceb::Executors::EventExecutor' do
  it 'should save event (new record)' do
    event = mock('MyEvent')
    event.should_receive(:new_record?).once.and_return(true)
    event.should_receive(:save!).once
    executor = ::Junkfood::Ceb::Executors::EventExecutor.new
    executor.call event
  end

  it 'should not save event (not new record)' do
    event = mock('Event')
    event.should_receive(:new_record?).once.and_return(false)
    executor = ::Junkfood::Ceb::Executors::EventExecutor.new
    executor.call event
  end
end
