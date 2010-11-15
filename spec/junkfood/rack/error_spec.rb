require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Junkfood::Rack' do
  describe 'ErrorHandler' do

    it 'should catch Exceptions and return a standard JSON error message' do
      # Set up expected return values.
      expected_headers = {
        'Content-Type' => 'application/json'
      }
      expected_hash_body = {
        'type' => 'Error',
        'code' => 'RuntimeError',
        'message' => 'My error message'
      }

      # Initialize the class under test.
      handler = Junkfood::Rack::ErrorHandler.new Proc.new {
        raise 'My error message'
      }

      # Execute the call to the middleware.
      env = {}
      status_code, headers, body = handler.call(env)

      # Check the return values
      status_code.should eql(500)
      headers.should eql(expected_headers)
      body_hash = JSON.parse body.join
      body_hash.should eql(expected_hash_body)
    end

    it 'should catch Exceptions and return a custom JSON error message' do
      # Set up expected return values.
      expected_headers = {
        'Content-Type' => 'application/json'
      }
      expected_hash_body = {
        'type' => 'Error',
        'code' => 'SomeCustomErrorCode',
        'message' => 'My CUSTOM error message'
      }

      # Initialize the class under test.
      handler = Junkfood::Rack::ErrorHandler.new(Proc.new {
        raise 'My error message'
      }, {
        'RuntimeError' => {
          'code' => 'SomeCustomErrorCode',
          'message' => 'My CUSTOM error message',
          'status_code' => 400
        }
      })

      # Execute the call to the middleware.
      env = {}
      status_code, headers, body = handler.call(env)

      # Check the return values
      status_code.should eql(400)
      headers.should eql(expected_headers)
      body_hash = JSON.parse body.join
      body_hash.should eql(expected_hash_body)
    end
  end
end
