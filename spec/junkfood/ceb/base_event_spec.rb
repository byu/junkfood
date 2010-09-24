require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Ceb::BaseEvent' do

  before :all do
    @command_class = Class.new(::Junkfood::Ceb::BaseCommand)
    @command_instance = @command_class.new
    @test_class = Class.new(::Junkfood::Ceb::BaseEvent)
    @test_instance = @test_class.new
    @test_instance.command = @command_instance
  end

  it 'should respond to new_record?' do
    @test_instance.respond_to?(:new_record?).should be_true
  end

  it 'should respond to save!' do
    @test_instance.respond_to?(:save!).should be_true
  end

  it 'should respond to valid?' do
    @test_instance.respond_to?(:valid?).should be_true
  end

  it 'should have id attribute' do
    @test_instance.respond_to?(:id).should be_true
  end

  it 'should have created_at attribute' do
    @test_instance.respond_to?(:created_at).should be_true
  end

  it 'should have command attributes' do
    @test_instance.respond_to?(:command).should be_true
    @test_instance.respond_to?(:command=).should be_true
    @test_instance.respond_to?(:command_id).should be_true
    @test_instance.respond_to?(:command_id=).should be_true
  end

  it 'should respond to to_json' do
    @test_instance.respond_to?(:to_json).should be_true
  end

  it 'json should have _id attribute' do
    json_data = @test_instance.to_json
    json_hash = JSON.parse json_data
    json_hash.key?('_id').should be_true
  end

  it 'json should have _type attribute' do
    json_data = @test_instance.to_json
    json_hash = JSON.parse json_data
    json_hash.key?('_type').should be_true
  end

  it 'json should have created_at attribute' do
    json_data = @test_instance.to_json
    json_hash = JSON.parse json_data
    json_hash.key?('created_at').should be_true
  end

  it 'json should have command_id attribute' do
    json_data = @test_instance.to_json
    json_hash = JSON.parse json_data
    json_hash.key?('command_id').should be_true
  end
end
