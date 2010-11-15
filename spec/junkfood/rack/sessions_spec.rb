require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Junkfood::Rack' do
  describe 'TransientSession' do

    it 'should set the rack.session env parameter with an empty hash' do
      # We manually create a rack application with the TransientSession
      # acting as the only middleware. The application itself is a
      # proc object that just checks that the passed rack environment
      # is a hash with the rack.session field set to an empty hash.
      # The test is checked when the app is called with an empty hash
      # that is to be transformed by the TransientSession middleware.
      app = Junkfood::Rack::TransientSession.new Proc.new { |env|
        env.should eql 'rack.session' => {}
        [200, {}, []]
      }
      app.call({})
    end
  end
end
