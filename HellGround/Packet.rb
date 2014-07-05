# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround
  class Packet
    # Initializes empty packet.
    def initialize(data = '')
      @data = data
      @pos = 0
    end

    # Returns packet content.
    def data
      @data
    end

    # Displays packet info.
    def dump
       puts "Packet #{self.class}, length #{length}"
       self.data.hexdump
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

    def int8;   read('c', 1) end
    def int16;  read('s', 2) end
    def int32;  read('l', 4) end
    def int64;  read('q', 8) end
    def uint8;  read('C', 1) end
    def uint16; read('S', 2) end
    def uint32; read('L', 4) end
    def uint64; read('Q', 8) end

    def int8=(d)   append('c', 1, d) end
    def int16=(d)  append('s', 2, d) end
    def int32=(d)  append('l', 4, d) end
    def int64=(d)  append('q', 8, d) end
    def uint8=(d)  append('C', 1, d) end
    def uint16=(d) append('S', 2, d) end
    def uint32=(d) append('L', 4, d) end
    def uint64=(d) append('Q', 8, d) end

    def uint32str=(s) append('a4', 4, s) end

    def str=(s)
      @data << s
      @pos += s.length
      self
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
end
