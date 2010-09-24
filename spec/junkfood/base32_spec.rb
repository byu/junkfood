require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Junkfood::Base32' do
  it 'should encode into an ASCII string' do
    str = Junkfood::Base32.encode '1234567890abcdefghijklmnopqrstuvwxyz'
    str.string.should eql(
      'GEZDGNBVGY3TQOJQMFRGGZDFMZTWQ2LKNNWG23TPOBYXE43UOV3HO6DZPI')
    str.string.encoding.should eql(Encoding::ASCII)
  end

  it 'should decode into a BINARY string' do
    str = Junkfood::Base32.decode(
      'GEZDGNBVGY3TQOJQMFRGGZDFMZTWQ2LKNNWG23TPOBYXE43UOV3HO6DZPI')
    str.string.should eql('1234567890abcdefghijklmnopqrstuvwxyz')
    str.string.encoding.should eql(Encoding::BINARY)
  end

  it 'should treat 0 and O the same' do
    str1 = Junkfood::Base32.decode('000000000')
    str2 = Junkfood::Base32.decode('oooOoooOo')
    str1.string.should eql(str2.string)
  end

  it 'should treat 1 and i the same' do
    str1 = Junkfood::Base32.decode('111111111')
    str2 = Junkfood::Base32.decode('iiiiIIIII')
    str1.string.should eql(str2.string)
  end

  it 'should ignore case' do
    str1 = Junkfood::Base32.decode('12345670abcdefghijklmnopqrstuvwxyz')
    str2 = Junkfood::Base32.decode('12345670ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    str1.string.should eql(str2.string)
  end

  it 'should have optional splitlines'

  it 'should have splitlines at specified lengths'
end
