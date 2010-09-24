require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'Ceb::Executors::CommandExecutor' do
  it 'should save and perform the command (and return results)' do
    expected_result = 'arbitrary return values'
    command = mock('MyCommand')
    command.should_receive(:new_record?).once.and_return(true)
    command.should_receive(:save!).once
    command.should_receive(:perform).once.and_return(expected_result)
    executor = ::Junkfood::Ceb::Executors::CommandExecutor.new
    result = executor.call command
    result.should eql(expected_result)
  end

  it 'should just perform the command (and return results) without saving' do
    expected_result = 'arbitrary return values'
    command = mock('MyCommand')
    command.should_receive(:new_record?).once.and_return(false)
    command.should_receive(:perform).once.and_return(expected_result)
    executor = ::Junkfood::Ceb::Executors::CommandExecutor.new
    result = executor.call command
    result.should eql(expected_result)
  end
end
