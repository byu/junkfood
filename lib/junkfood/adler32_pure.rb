# encoding: utf-8
# Copyright 2009 Benjamin Yu <http://benjaminyu.org/>
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

module Junkfood

  ##
  # A pure Ruby implementation of the Adler-32 checksum algorithm.
  #
  # This Ruby implementation is a port of the pure Python reference
  # implementation found in the pysync project. The Python reference
  # implementation, itself, was a port from zlib's adler32.c file.
  #
  # @example
  #   adler32 = Junkfood::Adler32Pure.new('Wikipedia')
  #   puts adler32.digest #=> 300286872
  #
  # @see http://zlib.net/
  # @see http://freshmeat.net/projects/pysync/
  #
  class Adler32Pure

    # largest prime smaller than 65536
    BASE = 65521
    # largest n such that 255n(n+1)/2 + (n+1)(BASE-1) <= 2^32-1
    NMAX = 5552
    # default initial s1 offset
    OFFS = 1

    ##
    # @param data (String) initial block of data to digest.
    #
    def initialize(data='')
      @count = 0
      @s2 = 0
      @s1 = OFFS
      self.update(data)
    end

    ##
    # Adds another block of data to digest.
    #
    # @param data (String) block of data to digest.
    # @return (Fixnum) the updated digest.
    #
    def update(data)
      i = 0
      while i < data.length
        data[i,i+NMAX].each_byte do |b|
          @s1 = @s1 + b
          @s2 = @s2 + @s1
        end
        @s1 = @s1 % BASE
        @s2 = @s2 % BASE
        i = i + NMAX
      end
      @count = @count + data.length
      return self.digest
    end

    ##
    # @param x1 (Byte)
    # @param xn (Byte)
    # @return (Fixnum) the updated digest.
    #
    def rotate(x1, xn)
      @s1 = (@s1 - x1 + xn) % BASE
      @s2 = (@s2 - (@count * x1) + @s1 - OFFS) % BASE
      return self.digest
    end

    ##
    # @param b (Byte)
    # @return (Fixnum) the updated digest.
    #
    def rollin(b)
      @s1 = (@s1 + b) % BASE
      @s2 = (@s2 + @s1) % BASE
      @count = @count + 1
      return self.digest
    end

    ##
    # @param b (Byte)
    # @return (Fixnum) the updated digest.
    #
    def rollout(b)
      @s1 = (@s1 - b) % BASE
      @s2 = (@s2 - @count * b) % BASE
      @count = @count - 1
      return self.digest
    end

    ##
    # @return (Fixnum) the current Adler32 digest value.
    #
    def digest
      return (@s2 << 16) | @s1
    end
  end
end
