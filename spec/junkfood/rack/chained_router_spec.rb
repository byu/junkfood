require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Junkfood::Rack' do
  describe 'ChainedRouter' do

    it 'should return a not found result if route set is empty' do
      # Set the not found expected results
      expected_results = [
        404,
        { 'X-Cascade' => 'pass', 'Content-Type' => 'text/plain'},
        []]

      # Create an empty router
      router = Junkfood::Rack::ChainedRouter.new

      # Execute and test
      results = router.call({})
      results.should eql expected_results
    end

    it 'should execute the next callable in chain when a pass is given' do
      expected_results = [200, {}, ['Hello World']]

      # Create the router
      app = Proc.new { |env|
        fail 'Should not be called'
      }
      router = Junkfood::Rack::ChainedRouter.new app do |router|
        # This proc is called, but it returns a pass.
        router.add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
        # This proc is called, but it also returns a pass.
        router.add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
        # This proc is called and returns success
        router.add_route Proc.new { |env|
          [200, {}, ['Hello World']]
        }
        router.add_route Proc.new { |env|
          fail 'Should not be called'
        }
      end

      # Execute and test
      results = router.call({})
      results.should eql expected_results
    end

    it 'should execute the app as the last callable in the chain' do
      expected_results = [200, {}, ['Hello World']]

      # Last app to be called
      app = Proc.new { |env|
        [200, {}, ['Hello World']]
      }

      # Create the router
      router = Junkfood::Rack::ChainedRouter.new app do |router|
        # This proc is called, but it returns a pass.
        router.add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
        # This proc is called, but it also returns a pass.
        router.add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
      end

      # Execute and test
      results = router.call({})
      results.should eql expected_results
    end

    it 'should return the last callable results even if it is a pass' do
      expected_results = [404, { 'X-Cascade' => 'pass' }, ['last']]

      # Last app to be called, and it's a pass
      app = Proc.new { |env|
        [404, { 'X-Cascade' => 'pass' }, ['last']]
      }
      # Create the router
      router = Junkfood::Rack::ChainedRouter.new app do |router|
        # This proc is called, but it returns a pass.
        router.add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
        # This proc is called, but it also returns a pass.
        router.add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
      end

      # Execute and test
      results = router.call({})
      results.should eql expected_results
    end

    it 'should have good instance_eval DSL (for 0 arity blocks)' do
      expected_results = [200, {}, ['Hello World']]

      # Create the router
      app = Proc.new { |env|
        fail 'Should not be called'
      }
      router = Junkfood::Rack::ChainedRouter.new app do
        # This proc is called, but it returns a pass.
        add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
        # This proc is called, but it also returns a pass.
        add_route Proc.new { |env|
          [404, { 'X-Cascade' => 'pass' }, []]
        }
        # This proc is called and returns success
        add_route Proc.new { |env|
          [200, {}, ['Hello World']]
        }
        add_route Proc.new { |env|
          fail 'Should not be called'
        }
      end

      # Execute and test
      results = router.call({})
      results.should eql expected_results
    end
  end
end
