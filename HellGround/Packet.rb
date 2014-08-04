# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require_relative 'Opcodes'

module HellGround
  # WoW packet object.
  class Packet
    # Returns packet contents.
    # @return [String] Byte string.
    def data
      @data
    end

    # Slices packet contents.
    # @param key [Fixnum|Range] Index or range.
    # @return [String|Nil] Byte string.
    def [](key)
      @data[key]
    end

    # Replaces selected data with given.
    # @param key [Fixnum|Range] Index or range.
    # @param value [String] Byte string.
    def []=(key, value)
      @data[key] = value
    end

    # Displays packet info: header and contents as hex dump.
    def dump
       puts self
       data.hexdump
    end

    # Returns num bytes of data from packet and increments position by num.
    def get(num = 1)
      ret = @data[@pos..(@pos+num-1)]
      @pos += num
      ret
    end

    # Returns packet length.
    def length
      @data.length
    end

    # Returns current position in the packet.
    def pos
      @pos
    end

    # Sets current position to pos.
    def pos=(pos)
      @pos = pos
      self
    end

    # Resets current position to zero.
    def reset
      @pos = 0
      self
    end

    # Skips num bytes and increments position by num.
    def skip(num = 1)
      @pos += num
      self
    end

    # Reads int8.
    # @return [Fixnum] int8
    def int8; read('c', 1) end

    # Reads int16.
    # @return [Fixnum] int16
    def int16; read('s', 2) end

    # Reads int32.
    # @return [Fixnum] int32
    def int32; read('l', 4) end

    # Reads int64.
    # @return [Fixnum] int64
    def int64; read('q', 8) end

    # Reads uint8.
    # @return [Fixnum] uint8
    def uint8; read('C', 1) end

    # Reads uint16.
    # @return [Fixnum] uint16
    def uint16; read('S', 2) end

    # Reads uint16. Usable when reading header size.
    # @return [Fixnum] uint16
    def size16; read('S>', 2) end

    # Reads uint32.
    # @return [Fixnum] uint32
    def uint32; read('L', 4) end

    # Reads uint64.
    # @return [Fixnum] uint64
    def uint64; read('Q', 8) end

    # Reads float.
    # @return [Float] float
    def float; read('g', 4) end

    # Reads double.
    # @return [Float] double
    def double; read('G', 8) end

    # Reads a C string, discarding \0 char.
    # @return [String] C string
    def str
      ret = @data[@pos..(@data.index("\0", @pos))] # read with \0
      @pos += ret.length
      ret.delete("\0") # discard \0
    end

    # Converts big-endian packed bytes into a number.
    # @param num [Fixnum] Byte count.
    # @return [Fixnum] number
    def hex(num)
      get(num).reverse.unpack('H*').first.hex # bytes need to be reversed
    end

    # Appends int8.
    # @param d [Fixnum] Number.
    def int8=(d); append('c', 1, d) end

    # Appends int16.
    # @param d [Fixnum] Number.
    def int16=(d); append('s', 2, d) end

    # Appends int32.
    # @param d [Fixnum] Number.
    def int32=(d); append('l', 4, d) end

    # Appends int64.
    # @param d [Fixnum] Number.
    def int64=(d); append('q', 8, d) end

    # Appends uint8.
    # @param d [Fixnum] Number.
    def uint8=(d); append('C', 1, d) end

    # Appends uint16.
    # @param d [Fixnum] Number.
    def uint16=(d); append('S', 2, d) end

    # Appends uint16. Usable when writing packet size to the header.
    # @param d [Fixnum] Number.
    def size16=(d); append('S>', 2, d) end

    # Appends uint32.
    # @param d [Fixnum] Number.
    def uint32=(d); append('L', 4, d) end

    # Appends uint64.
    # @param d [Fixnum] Number.
    def uint64=(d); append('Q', 8, d) end

    # Appends float.
    # @param d [Float] Number.
    def float=(d); append('g', 4, d) end

    # Appends double.
    # @param d [Float] Number.
    def double=(d); append('G', 8, d) end

    # Appends raw byte string.
    # @param s [String] Byte string.
    def raw=(s)
      @data << s
      @pos += s.length
      self
    end

    # Appends parameter as C string.
    # @param s [String] String to append.
    def str=(s)
      @data << s << "\0"
      @pos += s.length.succ
      self
    end

    protected

    # Initializes empty packet.
    def initialize(data = '')
      @@id ||= 0
      @@id += 1

      @data = data
      @pos = 0
    end

    private

    def read(type, bytes)
      ret = @data[@pos..(@pos+bytes)].unpack(type).first
      @pos += bytes
      ret
    end

    def append(type, bytes, data)
      @data << [data].pack(type)
      @pos += bytes
      self
    end

    # General packet error.
    class Error < StandardError; end

    # Malformed data error.
    class MalformedError < Error; end

    # Packet length error.
    class LengthError < Error; end
  end

  module Auth
    class Packet < HellGround::Packet
      # Returns auth packet opcode.
      # @return [Fixnum] Opcode.
      def opcode
        @data[0].unpack('C').first
      end

      def to_s
        format "<Packet #%u bytes:0x%02X op:0x%02X %s>",
          @@id, length, opcode, Opcodes.name(opcode) || '?'
      end
    end
  end

  module World
    class Packet < HellGround::Packet
      # Returns world packet length from header.
      # @return [Fixnum] Packet length.
      def hdrsize
        @data[0..1].unpack('S>').first
      end

      # Returns world packet opcode.
      # @return [Fixnum] Packet opcode.
      def opcode
        @data[2..3].unpack('S<').first
      end

      # Returns extra data after the end of packet.
      # @return [String|Nil] Overflow bytes.
      def overflow
        @data[2 + hdrsize .. -1]
      end

      # Returns underflow number. Positive indicates an incomplete packet.
      # @return [Fixnum] Underflow number.
      def underflow
        2 + hdrsize - length
      end

      def to_s
        format "<Packet #%u bytes:0x%02X size:0x%02X op:0x%04X %s>",
          @@id, length, hdrsize, opcode, Opcodes.name(opcode) || '?'
      end
    end
  end
end
