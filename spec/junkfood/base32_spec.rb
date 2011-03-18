require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Junkfood::Base32' do
  it 'should encode into an ASCII string' do
    str = Junkfood::Base32.encode '1234567890abcdefghijklmnopqrstuvwxyz'
    str.should eql(
      'GEZDGNBVGY3TQOJQMFRGGZDFMZTWQ2LKNNWG23TPOBYXE43UOV3HO6DZPI======')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should encode into an ASCII string, with no padding' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefghijklmnopqrstuvwxyz',
      :omit_pad => true)
    str.should eql(
      'GEZDGNBVGY3TQOJQMFRGGZDFMZTWQ2LKNNWG23TPOBYXE43UOV3HO6DZPI')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should decode into a BINARY string' do
    str = Junkfood::Base32.decode(
      'GEZDGNBVGY3TQOJQMFRGGZDFMZTWQ2LKNNWG23TPOBYXE43UOV3HO6DZPI======')
    str.should eql('1234567890abcdefghijklmnopqrstuvwxyz')
    str.encoding.should eql(Encoding::BINARY)
  end

  it 'should decode into a BINARY string when unpadded' do
    str = Junkfood::Base32.decode(
      'GEZDGNBVGY3TQOJQMFRGGZDFMZTWQ2LKNNWG23TPOBYXE43UOV3HO6DZPI')
    str.should eql('1234567890abcdefghijklmnopqrstuvwxyz')
    str.encoding.should eql(Encoding::BINARY)
  end

  it 'should treat 0 and O the same' do
    str1 = Junkfood::Base32.decode('000000000')
    str2 = Junkfood::Base32.decode('oooOoooOo')
    str1.should eql(str2)
  end

  it 'should treat 1 and i the same' do
    str1 = Junkfood::Base32.decode('111111111')
    str2 = Junkfood::Base32.decode('iiiiIIIII')
    str1.should eql(str2)
  end

  it 'should ignore case' do
    str1 = Junkfood::Base32.decode('12345670abcdefghijklmnopqrstuvwxyz')
    str2 = Junkfood::Base32.decode('12345670ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    str1.should eql(str2)
  end

  it 'should ignore padding characters in decode' do
    str1 = Junkfood::Base32.decode("12345-670ab cdefg_hijkl \n mnopqrstuvwxyz")
    str2 = Junkfood::Base32.decode('12345670ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    str1.should eql(str2)
  end

  it 'should end decoding on pad' do
    str = Junkfood::Base32.decode(
      'GEZDGNBVGY3TQOJQMFRGGZDFMZTWQ2LKNNWG23TPOBYXE43UOV3HO6DZPI=ABCDEFG')
    str.should eql('1234567890abcdefghijklmnopqrstuvwxyz')
    str.encoding.should eql(Encoding::BINARY)
  end

  it 'should support dash splits at every 10th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefghijklmnopqrstuvwxyz',
      :split => :dash,
      :split_length => 10)
    str.should eql(
      'GEZDGNBVGY-3TQOJQMFRG-GZDFMZTWQ2-LKNNWG23TP-OBYXE43UOV-3HO6DZPI======')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should support dash splits at every 10th character, unpadded' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefghijklmnopqrstuvwxyz',
      :split => :dash,
      :split_length => 10,
      :omit_pad => true)
    str.should eql(
      'GEZDGNBVGY-3TQOJQMFRG-GZDFMZTWQ2-LKNNWG23TP-OBYXE43UOV-3HO6DZPI')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should support newline splits at every 10th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefghijklmnopqrstuvwxyz',
      :split => :newline,
      :split_length => 10)
    str.should eql(
      "GEZDGNBVGY\n3TQOJQMFRG\nGZDFMZTWQ2\nLKNNWG23TP\nOBYXE43UOV\n3HO6DZPI======")
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should support newline splits at every 10th character, unpadded' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefghijklmnopqrstuvwxyz',
      :split => :newline,
      :split_length => 10,
      :omit_pad => true)
    str.should eql(
      "GEZDGNBVGY\n3TQOJQMFRG\nGZDFMZTWQ2\nLKNNWG23TP\nOBYXE43UOV\n3HO6DZPI")
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should support space splits at every 5th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefgh',
      :split => :space,
      :split_length => 5)
    str.should eql(
      'GEZDG NBVGY 3TQOJ QMFRG GZDFM ZTWQ===')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should support space splits at every 5th character, unpadded' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefgh',
      :split => :space,
      :split_length => 5,
      :omit_pad => true)
    str.should eql(
      'GEZDG NBVGY 3TQOJ QMFRG GZDFM ZTWQ')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should support underscore splits at every 4th character' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefgh',
      :split => :underscore,
      :split_length => 4)
    str.should eql(
      'GEZD_GNBV_GY3T_QOJQ_MFRG_GZDF_MZTW_Q===')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should support underscore splits at every 4th character, unpadded' do
    str = Junkfood::Base32.encode(
      '1234567890abcdefgh',
      :split => :underscore,
      :split_length => 4,
      :omit_pad => true)
    str.should eql(
      'GEZD_GNBV_GY3T_QOJQ_MFRG_GZDF_MZTW_Q')
    str.encoding.should eql(Encoding::ASCII)
  end

  it 'should pad correctly' do
    str = Junkfood::Base32.encode ''
    str.should eql('')
    str = Junkfood::Base32.encode '1'
    str.should eql('GE======')
    str = Junkfood::Base32.encode '12'
    str.should eql('GEZA====')
    str = Junkfood::Base32.encode '123'
    str.should eql('GEZDG===')
    str = Junkfood::Base32.encode '1234'
    str.should eql('GEZDGNA=')
    str = Junkfood::Base32.encode '12345'
    str.should eql('GEZDGNBV')
    str = Junkfood::Base32.encode '567890'
    str.should eql('GU3DOOBZGA======')
    str = Junkfood::Base32.encode '567890A'
    str.should eql('GU3DOOBZGBAQ====')
    str = Junkfood::Base32.encode '567890AB'
    str.should eql('GU3DOOBZGBAUE===')
    str = Junkfood::Base32.encode '567890ABC'
    str.should eql('GU3DOOBZGBAUEQY=')
    str = Junkfood::Base32.encode '567890ABCD'
    str.should eql('GU3DOOBZGBAUEQ2E')
  end

  it 'should omit padding correctly' do
    str = Junkfood::Base32.encode '', :omit_pad => true
    str.should eql('')
    str = Junkfood::Base32.encode '1', :omit_pad => true
    str.should eql('GE')
    str = Junkfood::Base32.encode '12', :omit_pad => true
    str.should eql('GEZA')
    str = Junkfood::Base32.encode '123', :omit_pad => true
    str.should eql('GEZDG')
    str = Junkfood::Base32.encode '1234', :omit_pad => true
    str.should eql('GEZDGNA')
    str = Junkfood::Base32.encode '12345', :omit_pad => true
    str.should eql('GEZDGNBV')
    str = Junkfood::Base32.encode '567890', :omit_pad => true
    str.should eql('GU3DOOBZGA')
    str = Junkfood::Base32.encode '567890A', :omit_pad => true
    str.should eql('GU3DOOBZGBAQ')
    str = Junkfood::Base32.encode '567890AB', :omit_pad => true
    str.should eql('GU3DOOBZGBAUE')
    str = Junkfood::Base32.encode '567890ABC', :omit_pad => true
    str.should eql('GU3DOOBZGBAUEQY')
    str = Junkfood::Base32.encode '567890ABCD', :omit_pad => true
    str.should eql('GU3DOOBZGBAUEQ2E')
  end
end
