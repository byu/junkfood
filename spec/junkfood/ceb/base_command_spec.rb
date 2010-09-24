require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Ceb::BaseCommand' do
  before :all do
    @test_class = Class.new(::Junkfood::Ceb::BaseCommand)
    @test_instance = @test_class.new
    @test_instance.origin = 'urn:user_id:1234'
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

  it 'should have origin attribute' do
    @test_instance.respond_to?(:origin).should be_true
  end

  it 'may have events' do
    # NOTE: This is not a hard requirement. We mainly want the coupling
    #  to be looser. It's sufficient for Events to link to Commands,
    #  and not necesarily need Commands to map to all of its Events.
    # This test is here because we have a Mongoid MongoDb implementation.
    @test_instance.respond_to?(:events).should be_true
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

  it 'json should have origin attribute' do
    json_data = @test_instance.to_json
    json_hash = JSON.parse json_data
    json_hash.key?('origin').should be_true
  end

  it 'should respond to perform' do
    @test_instance.respond_to?(:perform).should be_true
  end
end
