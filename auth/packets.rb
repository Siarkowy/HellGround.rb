# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::Auth
  # Client packet classes

  class ClientLogonChallenge < Packet
    def initialize(username)
      super()

      raise ArgumentError, "User name too short" if username.length == 0
      raise ArgumentError, "User name too long" if username.length > 32

      self.uint8  = MSG::MSG_AUTH_LOGON_CHALLENGE # type
      self.uint8  = 8                     # error
      self.uint16 = 30 + username.length  # size
      self.raw    = "\0WoW".reverse       # gamename
      self.uint8  = 2                     # version1
      self.uint8  = 4                     # version2
      self.uint8  = 3                     # version3
      self.uint16 = 8606                  # build
      self.raw    = "\0x86".reverse       # platform
      self.raw    = "\0Cha".reverse       # os
      self.raw    = "enGB".reverse        # locale
      self.uint32 = 60                    # timezone
      self.uint32 = 0x0100A8C0            # ip
      self.uint8  = username.length       # namelen
      self.raw    = username.upcase       # account

      raise PacketLengthError unless length == 34 + username.length
    end
  end

  class ClientLogonProof < Packet
    def initialize(a, m1, crc_hash)
      super()

      self.uint8  = MSG::MSG_AUTH_LOGON_PROOF # type
      self.raw    = a.hexpack(32)         # A
      self.raw    = m1.hexpack(20)        # M1
      self.raw    = crc_hash.hexpack(20)  # crc_hash unused
      self.uint8  = 0                     # num keys
      self.uint8  = 0                     # sec flag

      raise PacketLengthError unless length == 75
    end
  end

  class ClientRealmList < Packet
    def initialize
      super()

      self.uint8  = MSG::MSG_REALM_LIST   # type
      self.uint32 = 0                     # pad

      raise PacketLengthError unless length == 5
    end
  end
end
