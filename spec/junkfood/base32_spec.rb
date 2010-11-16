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

  it 'should support dash splits at every 10th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefghijklmnopqrstuvwxyz',
      :split => :dash,
      :split_length => 10)
    str.string.should eql(
      'GEZDGNBVGY-3TQOJQMFRG-GZDFMZTWQ2-LKNNWG23TP-OBYXE43UOV-3HO6DZPI')
    str.string.encoding.should eql(Encoding::ASCII)
  end

  it 'should support newline splits at every 10th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefghijklmnopqrstuvwxyz',
      :split => :newline,
      :split_length => 10)
    str.string.should eql(
      "GEZDGNBVGY\n3TQOJQMFRG\nGZDFMZTWQ2\nLKNNWG23TP\nOBYXE43UOV\n3HO6DZPI")
    str.string.encoding.should eql(Encoding::ASCII)
  end

  it 'should support space splits at every 5th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefgh',
      :split => :space,
      :split_length => 5)
    str.string.should eql(
      'GEZDG NBVGY 3TQOJ QMFRG GZDFM ZTWQ')
    str.string.encoding.should eql(Encoding::ASCII)
  end

  it 'should support underscore splits at every 4th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefgh',
      :split => :underscore,
      :split_length => 4)
    str.string.should eql(
      'GEZD_GNBV_GY3T_QOJQ_MFRG_GZDF_MZTW_Q')
    str.string.encoding.should eql(Encoding::ASCII)
  end
end
