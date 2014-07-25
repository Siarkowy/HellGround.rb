# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

class Numeric
  # Returns byte representation of the number for packet storage.
  def hexpack(bytes = 0) # FIXME: Move to utilities.
    ["%0#{2 * bytes}x" % self].pack('H*').reverse
  end
end

module HellGround
  module Utils
    def sha1(str)
      Digest::SHA1.digest(str).reverse.unpack('H*').first.hex
    end
  end
end
