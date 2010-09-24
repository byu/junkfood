# encoding: utf-8
# Copyright 2010 Benjamin Yu <http://benjaminyu.org/>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'openssl'
require 'wrong'

module Junkfood

  ##
  # Implements HMAC One Time Passwords using SHA-1 digests.
  #
  # @example
  #
  #   # Using the class methods to get OTP one at a time.
  #   key = '12345678901234567890'
  #   puts Junkfood::OneTime.hotp(key, 0) #=> 755224
  #   puts Junkfood::OneTime.hotp(key, 1) #=> 287082
  #
  # @example
  #
  #   # Changing the length of the OTP
  #   key = '12345678901234567890'
  #   puts Junkfood::OneTime.hotp(key, 0, :digits => 8) #=> 84755224
  #
  # @example
  #
  #   # Using the class methods to get multiple OTP at a time.
  #   key = '12345678901234567890'
  #   puts Junkfood::OneTime.hotp_multi(key, 0..1) #=> [755224, 287082]
  #
  # @example
  #
  #   # Create a new OTP generator starting at counter 0.
  #   key = '12345678901234567890'
  #   one_time = Junkfood::OneTime.new key
  #   # Get an OTP, but don't advance the counter
  #   puts one_time.otp #=> 755224
  #   puts one_time.otp #=> 755224
  #   # Get a range of OTP
  #   puts one_time.otp :range => 2 #=> [755224, 287082]
  #   # Get an OTP, and advance the counter
  #   puts one_time.otp! #=> 755224
  #   puts one_time.otp! #=> 287082
  #   puts one_time.counter #=> 2
  #   puts one_time.otp! :range => 2 #=> [359152, 969429]
  #   puts one_time.counter #=> 4
  #
  # @example
  #
  #   # The current Time based OTP for the current epoch step.
  #   key = '12345678901234567890'
  #   one_time = Junkfood::OneTime.new key
  #   puts one_time.totp
  #   # A bunch of OTPs preceding and following the current epoch step OTP.
  #   puts one_time.totp :radius => 2
  #
  # @example
  #
  #   # Setting the length and counter of the OTP on a OneTime instance
  #   one_time = Junkfood::OneTime.new key, :digits => 8, :counter => 2
  #   puts one_time.otp! #=> 37359152
  #   puts one_time.otp! #=> 26969429
  #
  # @see http://tools.ietf.org/html/rfc4226
  # @see http://tools.ietf.org/html/draft-mraihi-totp-timebased-06
  #
  class OneTime
    include ::Wrong::Assert

    attr_reader :counter

    # Default number of digits for each OTP.
    DEFAULT_DIGITS = 6
    # Default number of seconds for each step in the Time Epoch calculation.
    DEFAULT_STEP_SIZE = 30
    # Max number of OTPs preceding and following the current Time based OTP
    # allowed in the Time based OTP method.
    MAX_RADIUS = 10

    ##
    # @param secret (String) the secret key used for the HMAC calculation.
    # @option options [Fixnum] :counter (0) the htop counter to start at.
    # @option options [Fixnum] :digits (6) size of each OTP.
    # @option options [Fixnum] :time_digits (6) size of each Time Based OTP.
    # @option options [Fixnum] :time_step_size (30) number of seconds for
    #   each block in calculating current counter in Time Based OTP.
    def initialize(secret, options={})
      @secret = secret
      @counter = options[:counter] || 0
      @digits = options[:digits] || DEFAULT_DIGITS
      @time_digits = options[:time_digits] || @digits
      @time_step_size = options[:time_step_size] || DEFAULT_STEP_SIZE
    end

    ##
    # Generate counter based OTPs and advance the counter.
    #
    # @option options [Fixnum] :range (1) number of OTPs to generate.
    # @return [Array<String>,String] the generated OTPs.
    def otp!(options={})
      range = options[:range] || 1
      result = otp :range => range
      @counter += range
      return result
    end

    ##
    # Generate counter based OTPs without advancing the counter.
    #
    # @option options [Fixnum] :range (1) number of OTPs to generate.
    # @return [Array<String>,String] the generated OTPs.
    def otp(options={})
      range = options[:range] || 1
      if range <= 1
        return self.class.hotp(@secret, @counter, :digits => @digits)
      else
        return self.class.hotp_multi(
          @secret,
          @counter...(@counter + range),
          :digits => @digits)
      end
    end

    ##
    # Generate Time Based OTPs based on the current time and time steps.
    #
    # @option options [Fixnum] :radius (0) number of additional OTPs
    #   preceding and following the current Time OTP to generate.
    # @return [Array<String>,String] the generated OTPs.
    def totp(options={})
      radius = options[:radius] || 0
      assert{radius.kind_of?(Fixnum) && radius >= 0 && radius <= MAX_RADIUS}
      c = self.class.epoch_counter(:step_size => @time_step_size)
      start_counter = max(c - radius, 0)
      range = start_counter..(c+radius)
      results = self.class.hotp_multi @secret, range, :digits => @time_digits
      return results.size <= 1 ? results.first : results
    end

    ##
    # Generate an individual OTP.
    #
    # @param secret (String) the secret key used for the HMAC.
    # @param counter (Fixnum) the counter used to generate the OTP.
    # @option options [Fixnum] :digits (6) size of each OTP.
    # @return [String] the generated OTP.
    def self.hotp(secret, counter=0, options={})
      results = hotp_raw secret, counter, (options[:digits] || DEFAULT_DIGITS)
      return results.first
    end

    ##
    # Generate a set of OTPs.
    #
    # @param secret (String) the secret key used for the HMAC calculation.
    # @param range (Fixnum,Range) counters for which to generate OTPs
    # @option options [Fixnum] :digits (6) size of each OTP.
    # @return [String] the generated OTPs.
    def self.hotp_multi(secret, range, options={})
      digits = options[:digits] || DEFAULT_DIGITS
      range = range..range if range.kind_of? Fixnum
      range.map do |c|
        (hotp_raw secret, c, digits).first
      end
    end

    ##
    # Generate the OTP along with additional debug information.
    #
    # @param secret (String) the secret key used for the HMAC calculation.
    # @param counter (Fixnum) the htop counter to use at.
    # @param digits (Fixnum) size of each OTP.
    # @return [Array<String,Fixnum,String>] The generated OTP, the Dynamic
    #   Binary Code, and the calculated HMAC digest for the OTP.
    #
    def self.hotp_raw(secret, counter=0, digits=DEFAULT_DIGITS)
      # TODO: figure out a better way to turn fixnum into an 8byte buffer string
      counter_bytes = []
      x = counter
      for i in 0..7
        byte = x & 0xff
        x >>= 8
        counter_bytes.unshift byte
      end
      digest_data = counter_bytes.pack('C8')

      # SHA1 digest is guaranteed to produce a 20 byte binary string.
      # We unpack the string into an array of 8-bit bytes.
      digest = OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        secret,
        digest_data)
      digest_array = digest.unpack('C20')

      # Based on the HMAC OTP algorithm, we use the last 4 bits of the binary
      # string to find the 'dbc' value. The 4 bits is the offset of the
      # hmac bytes array. From which, we extract 4 bytes for the 'dbc'.
      # This is the "Dynamic Truncation".
      # We zero the most significant bit of the 'dbc' to get a 31-bit
      # unsigned big-endian integer. This dbc (converted to a Ruby Fixnum).
      # From the fix num, we modulo 10^digits to get the digits for the HOTP.
      # This is the "Compute HOTP value" step
      offset = digest_array.last & 0x0f
      dbc = digest_array[offset..(offset+3)]
      dbc[0] &= 0x7f
      dbc = dbc.pack('C4').unpack('N').first
      otp = (dbc % 10**digits).to_s.rjust(digits,'0')
      return otp, dbc, digest
    end

    ##
    # Generate the counter based on the time and step_size.
    #
    # @option options [Time] :time (Time.now) the time to use.
    # @option options [Fixnum] :step_size (30) the step size.
    # @return the time based counter.
    def self.epoch_counter(options={})
      time = options[:time] || Time.now.to_i
      step_size = options[:step_size] || DEFAULT_STEP_SIZE
      return time / step_size
    end

    private

    ##
    # Helper method to return the larger of two values.
    #
    # @param a (Object)
    # @param b (Object)
    # @return [Boolean] a &gt;= b ? a : b
    def max(a, b)
      return a >= b ? a : b
    end
  end
end
