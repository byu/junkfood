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

require 'stringio'

module Junkfood

  ##
  # Error class raised when an invalid Base32 character encoding is encountered.
  #
  class Base32DecodeError < StandardError
  end

  ##
  # Base32 (RFC4668/3548) encodes and decodes strings of data.
  #
  # Requires at least Ruby 1.9
  #
  # @see http://tools.ietf.org/html/rfc4648
  #
  class Base32
    # The Base32 alphabet, all caps.
    ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'
    ALPHABET.freeze
    # The Base32 alphabet, all lowercase.
    ALPHABET_DOWNCASE = ALPHABET.downcase
    ALPHABET_DOWNCASE.freeze
    PAD = ['', '======', '====', '===', '='].freeze

    # Once populated, this is Base32 alphabet to byte mapping.
    BYTE_MAP = {}
    (0..(ALPHABET.size)).each do |i|
      BYTE_MAP[ALPHABET.getbyte(i)] = i
      BYTE_MAP[ALPHABET_DOWNCASE.getbyte(i)] = i
    end
    # This is clear up confusions between the pairs: 1 and I, 0 and O.
    BYTE_MAP['1'.getbyte(0)] = BYTE_MAP['I'.getbyte(0)]
    BYTE_MAP['0'.getbyte(0)] = BYTE_MAP['O'.getbyte(0)]
    BYTE_MAP.freeze

    PAD_BYTE = '='.getbyte(0).freeze

    # Spacer characters to ignore when parsing a Base32 encoded string.
    IGNORED = "\r\n-_\s".bytes.to_a
    IGNORED.freeze

    ##
    # The hash of available break strings that can be inserted between
    # X number of Base32 characters (during the encoding process).
    SPLITS = {
      dash: '-', 
      newline: "\n",
      space: ' ',
      underscore: '_'
    }.freeze

    ##
    # Base32 encodes the input object and writes to the output io object.
    #
    # @param input [#each_byte]
    # @option options [#putc] :output (StringIO.new) of the output IO.
    # @option options [String] :split :dash, :newline, :space, or :underscore
    # @option options [Fixnum] :split_length (79) number of Base32 characters
    #   before inserting a split character.
    # @option options [Boolean] :omit_pad (false) omit the trailing pad (=)
    #   characters from the end of output.
    # @return IO, StringIO instance of object to which encoded data was written.
    #
    def self.encode(input, options={})
      output = options[:output] || StringIO.new(''.force_encoding('US-ASCII'))
      alphabet = options[:use_downcase] ? ALPHABET_DOWNCASE : ALPHABET
      write_pad = options[:omit_pad] ? false : true

      split = SPLITS[options[:split]]
      split_length = options[:split_length] || 79

      # Set up the lambda that does the actual work of writing the
      # quintet to the output stream.
      if split
        # This lambda will split up the output stream with a "break" character
        # for every N quintets (where N is the split_length).
        split_count = 0
        write = lambda do |quintet|
          output.putc alphabet.getbyte(quintet)
          split_count += 1
          if split_count >= split_length
            output.putc split 
            split_count = 0
          end
        end
      else
        # This lambda just writes out the quintets
        write = lambda do |quintet|
          output.putc alphabet.getbyte(quintet)
        end
      end

      position = 0
      buffer = 0
      input.each_byte do |byte|
        case position
        when 0
          # Current Buffer: 0 bits from previous byte
          # Quintet: 5 bits from current byte
          # New Buffer: Lowest 3 bits of current byte
          write.call(byte >> 3)
          buffer = byte & 0x07
        when 1
          # Current Buffer: 3 bits from previous byte
          # Quintet 1: 3 bits of buffer and first 2 bits of current byte
          # Quintet 2: next 5 bits of byte
          # New Buffer: Lowest 1 bit of current byte
          write.call((buffer << 2) | (byte >> 6))
          write.call((byte >> 1) & 0x1f)
          buffer = byte & 0x01
        when 2
          # Current Buffer: 1 bits from previous byte
          # Quintet 1: 1 bits of buffer and 4 bits of current byte
          # New Buffer: Lowest 4 bits of current byte
          write.call((buffer << 4) | (byte >> 4))
          buffer = byte & 0x0f
        when 3
          # Current Buffer: 4 bits from previous byte
          # Quintet 1: 4 bits of buffer and top bit of byte
          # Quintet 2: next 5 bits of byte
          # New Buffer: bottom 2 bit of byte
          write.call((buffer << 1) | (byte >> 7))
          write.call((byte >> 2) & 0x1f)
          buffer = byte & 0x03
        when 4
          # Current Buffer: 2 bits from previous byte
          # Quintet 1: 2 bits of buffer and top 3 bits of byte
          # Quintet 2: bottom 5 bits of byte
          write.call((buffer << 3) | (byte >> 5))
          write.call(byte & 0x1f) 
          buffer = 0
        end
        position = (position + 1) % 5
      end
      case position
      when 0
        # We are 40-bit aligned, so nothing to do.
      when 1
        # 3 bits in buffer
        write.call(buffer << 2)
      when 2
        # 1 bit in buffer
        write.call(buffer << 4)
      when 3
        # 4 bits in buffer
        write.call(buffer << 1)
      when 4
        # 2 bits in buffer
        write.call(buffer << 3)
      end
      output.write PAD[position] if write_pad

      return output
    end

    ##
    # Base32 decodes the input object and writes to the output io object.
    #
    # @param input [#each_byte]
    # @option options [#putc] :output (StringIO.new) of the output IO.
    #   before inserting a split character.
    # @return IO, StringIO instance of object to which decoded data was written.
    # @raise Base32DecodeError
    #
    def self.decode(input, options={})
      output = options[:output] || StringIO.new(''.force_encoding('BINARY'))
      buffer = 0
      bits_left = 0
      input.each_byte do |byte|
        break if byte == PAD_BYTE
        next if IGNORED.include? byte
        raise Base32DecodeError.new("Invalid input byte: #{byte}") unless(
          BYTE_MAP.key? byte)
        buffer = (buffer << 5) | BYTE_MAP[byte]
        bits_left += 5
        if bits_left >= 8
          bits_left -= 8
          output.putc(buffer >> bits_left)
          buffer &= (2 ** bits_left - 1)
        end
      end
      # We ignore remaining bits in the buffer in cases where there is an
      # incomplete Base32 quantum (ie, the number of characters are unaligned
      # with the 40-bit boundries).

      return output
    end
  end
end
