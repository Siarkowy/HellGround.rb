# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require_relative 'Opcodes'

module HellGround
  class Packet
    @@id = 0

    # Returns packet content.
    def data
      @data
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

    # Displays packet info.
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

    def int8
      read('c', 1)
    end

    def int16
      read('s', 2)
    end

    def int32
      read('l', 4)
    end

    def int64
      read('q', 8)
    end

    def uint8
      read('C', 1)
    end

    def uint16
      read('S', 2)
    end

    def size16
      read('S>', 2)
    end

    def uint32
      read('L', 4)
    end

    def uint64
      read('Q', 8)
    end

    def float
      read('g', 4)
    end

    def double
      read('G', 8)
    end

    # Reads a C string, discarding \0 char.
    def str
      ret = @data[@pos..(@data.index("\0", @pos))] # read with \0
      @pos += ret.length
      ret.delete("\0") # discard \0
    end

    # Converts big-endian packed bytes into a number.
    def hex(num)
      get(num).reverse.unpack('H*').first.hex # bytes need to be reversed
    end

    def int8=(d)
      append('c', 1, d)
    end

    def int16=(d)
      append('s', 2, d)
    end

    def int32=(d)
      append('l', 4, d)
    end

    def int64=(d)
      append('q', 8, d)
    end

    def uint8=(d)
      append('C', 1, d)
    end

    def uint16=(d)
      append('S', 2, d)
    end

    def size16=(d)
      append('S>', 2, d)
    end

    def uint32=(d)
      append('L', 4, d)
    end

    def uint64=(d)
      append('Q', 8, d)
    end

    def float=(d)
      append('g', 4, d)
    end

    def double=(d)
      append('G', 8, d)
    end

    # Appends raw byte string.
    def raw=(s)
      @data << s
      @pos += s.length
      self
    end

    # Appends param as C string.
    def str=(s)
      @data << s << "\0"
      @pos += s.length.succ
      self
    end

    protected

    # Initializes empty packet.
    def initialize(data = '')
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
  end

  module Auth
    class Packet < HellGround::Packet
      # Returns world packet opcode as reported by packet header.
      def opcode
        @data[0].unpack('C').first
      end

      def to_s
        format "<Packet #%u bytes:0x%02X op:0x%02X %s>",
          @@id, length, opcode, MSG.opcode_name(opcode) || '?'
      end
    end
  end

  module World
    class Packet < HellGround::Packet
      # Returns world packet length as reported by packet header.
      def hdrsize
        @data[0..1].unpack('S>').first
      end

      # Returns world packet opcode as reported by packet header.
      def opcode
        @data[2..3].unpack('S<').first
      end

      # Returns extra data after the packet's end.
      def overflow
        @data[2 + hdrsize .. -1]
      end

      # Returns underflow number. Positive indicates an incomplete packet.
      def underflow
        2 + hdrsize - length
      end

      def to_s
        format "<Packet #%u bytes:0x%02X size:0x%02X op:0x%04X %s>",
          @@id, length, hdrsize, opcode, MSG.opcode_name(opcode) || '?'
      end
    end
  end

  class PacketError < StandardError; end
  class MalformedPacketError < PacketError; end
  class PacketLengthError < PacketError; end
  class UnsupportedPacketError < PacketError; end
end
