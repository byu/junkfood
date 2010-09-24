require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "OneTime" do

  it 'should pass RFC 4226 Appendix D Test Values' do
    # Validates the first 10 OTPs for the RFC's test HOTP key (in RFC4226).
    key = '12345678901234567890'
    expected_results = [
      '755224',
      '287082',
      '359152',
      '969429',
      '338314',
      '254676',
      '287922',
      '162583',
      '399871',
      '520489',
    ] 
    for x in 0..9
      Junkfood::OneTime.hotp(key, x).should eql(expected_results[x])
    end
  end

  it 'should bulk pass RFC 4226 Appendix D Test Values' do
    # Validates the first 10 OTPs for the RFC's test HOTP key (in RFC4226).
    key = '12345678901234567890'
    expected_results = [
      '755224',
      '287082',
      '359152',
      '969429',
      '338314',
      '254676',
      '287922',
      '162583',
      '399871',
      '520489',
    ] 
    results = Junkfood::OneTime.hotp_multi(
      key,
      0...expected_results.size)
    results.should eql(expected_results)
  end

  it 'should provide low level details about algorithm values' do
    key = '12345678901234567890'
    expected_results = [
      ['755224', 1284755224, 'cc93cf18508d94934c64b65d8ba7667fb7cde4b0'],
      ['287082', 1094287082, '75a48a19d4cbe100644e8ac1397eea747a2d33ab'],
      ['359152', 137359152, '0bacb7fa082fef30782211938bc1c5e70416ff44'],
      ['969429', 1726969429, '66c28227d03a2d5529262ff016a1e6ef76557ece'],
      ['338314', 1640338314, 'a904c900a64b35909874b33e61c5938a8e15ed1c'],
      ['254676', 868254676, 'a37e783d7b7233c083d4f62926c7a25f238d0316'],
      ['287922', 1918287922, 'bc9cd28561042c83f219324d3c607256c03272ae'],
      ['162583', 82162583, 'a4fb960c0bc06e1eabb804e5b397cdc4b45596fa'],
      ['399871', 673399871, '1b3c89f65e6c9e883012052823443f048b4332db'],
      ['520489', 645520489, '1637409809a679dc698207310c8c7fc07290d9e5']
    ]
    for counter in 0...(expected_results.size)
      results = Junkfood::OneTime.hotp_raw(key, counter)
      results.size.should eql(3)
      # Our hmac digest is a binary string, but we want to convert it into
      # readable hex strings that we have in this spec's expected results.
      results[2] = results[2].unpack('H*').first
      results.should eql(expected_results[counter])
    end
  end

  it 'should start counter at 0' do
    key = '12345678901234567890'
    one_time = Junkfood::OneTime.new key
    one_time.counter.should eql(0)
  end

  it 'otp method should generate values without advancing counter' do
    key = '12345678901234567890'
    one_time = Junkfood::OneTime.new key
    first = one_time.otp
    first.should eql('755224')
    second = one_time.otp
    second.should eql('755224')
    one_time.counter.should eql(0)
  end

  it 'bulk otp method should generate values without advancing counter' do
    key = '12345678901234567890'
    one_time = Junkfood::OneTime.new key
    first = one_time.otp :range => 2
    first.should eql(['755224', '287082'])
    one_time.counter.should eql(0)
  end

  it 'otp! method should advance counter' do
    key = '12345678901234567890'
    one_time = Junkfood::OneTime.new key
    first = one_time.otp!
    first.should eql('755224')
    one_time.counter.should eql(1)
    second = one_time.otp!
    second.should eql('287082')
    one_time.counter.should eql(2)
  end

  it 'bulk otp! method should advance counter' do
    key = '12345678901234567890'
    one_time = Junkfood::OneTime.new key
    first = one_time.otp! :range => 2
    first.should eql(['755224', '287082'])
    one_time.counter.should eql(2)
  end

  it 'should generate counter from epoch for Time Based HOTP' do
    # RFC:
    # TOTP: Time-based One-time Password Algorithm

    # Test time values taken from the TOTP RFC Draft 5, Appendix B
    Junkfood::OneTime.epoch_counter(
      :time => 59,
      :step_size => 30).should eql(1)
    Junkfood::OneTime.epoch_counter(
      :time => 1111111109,
      :step_size => 30).should eql(37037036)
    Junkfood::OneTime.epoch_counter(
      :time => 1111111111,
      :step_size => 30).should eql(37037037)
    Junkfood::OneTime.epoch_counter(
      :time => 1234567890,
      :step_size => 30).should eql(41152263)
    Junkfood::OneTime.epoch_counter(
      :time => 2000000000,
      :step_size => 30).should eql(66666666)

    # Now using the implicit default step size
    Junkfood::OneTime::DEFAULT_STEP_SIZE.should eql(30)
    Junkfood::OneTime.epoch_counter(
      :time => 59).should eql(1)
    Junkfood::OneTime.epoch_counter(
      :time => 1111111109).should eql(37037036)
    Junkfood::OneTime.epoch_counter(
      :time => 1111111111).should eql(37037037)
    Junkfood::OneTime.epoch_counter(
      :time => 1234567890).should eql(41152263)
    Junkfood::OneTime.epoch_counter(
      :time => 2000000000).should eql(66666666)

    # Testing alternate step sizes
    Junkfood::OneTime.epoch_counter(
      :time => 59,
      :step_size => 60).should eql(0)
    Junkfood::OneTime.epoch_counter(
      :time => 59,
      :step_size => 15).should eql(3)
    Junkfood::OneTime.epoch_counter(
      :time => 59,
      :step_size => 59).should eql(1)
    Junkfood::OneTime.epoch_counter(
      :time => 59,
      :step_size => 1).should eql(59)
    Junkfood::OneTime.epoch_counter(
      :time => 59,
      :step_size => 2).should eql(29)
    Junkfood::OneTime.epoch_counter(
      :time => 2000000000,
      :step_size => 15).should eql(133333333)
  end
end
