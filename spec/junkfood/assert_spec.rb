require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Assert" do

  it 'should pass with various yielded results' do
    x = Class.new do
      include Junkfood::Assert
      def test
        assert { true }
        assert { 1 }
        assert { Array.new }
        assert { Hash.new }
      end
    end
    x.new.test
  end

  it 'should raise Assertion Error with false' do
    x = Class.new do
      include Junkfood::Assert
      def test
        assert { false }
      end
    end
    lambda {
      x.new.test
    }.should raise_error(Junkfood::Assert::AssertionFailedError)
  end

  it 'should raise Assertion Error with nil' do
    x = Class.new do
      include Junkfood::Assert
      def test
        assert { nil }
      end
    end
    lambda {
      x.new.test
    }.should raise_error(Junkfood::Assert::AssertionFailedError)
  end

  it 'should raise Assertion Error with custom message' do
    x = Class.new do
      include Junkfood::Assert
      def test
        assert('my custom error message') {
          false
        }
      end
    end
    lambda {
      x.new.test
    }.should raise_error(
      Junkfood::Assert::AssertionFailedError,
      'my custom error message')
  end

  it 'should call the parent class assert method when no block is given' do
    x = Class.new do
      def assert(*args)
        return args.first
      end
    end
    y = Class.new(x) do
      include Junkfood::Assert
      def test
        result = assert true
        assert { result }
      end
    end
    y.new.test
  end

  it 'should raise an error on missing block and undefined parent assert' do
    x = Class.new
    y = Class.new(x) do
      include Junkfood::Assert
      def test
        assert
      end
    end
    lambda { y.new.test }.should raise_error
  end
end
