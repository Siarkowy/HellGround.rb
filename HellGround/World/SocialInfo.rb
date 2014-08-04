# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Social info object. Stores friend or ignore information.
  class SocialInfo
    FRIEND_STATUS_OFFLINE   = 0x00
    FRIEND_STATUS_ONLINE    = 0x01
    FRIEND_STATUS_AFK       = 0x02
    FRIEND_STATUS_DND       = 0x04
    FRIEND_STATUS_RAF       = 0x08

    SOCIAL_FLAG_FRIEND      = 0x01

    attr_reader :guid, :flags, :note, :status, :zone, :level, :cls

    # @param guid [Fixnum] Character GUID.
    # @param flags [Fixnum] Social flags.
    # @param note [String] Friend note.
    # @param status [Fixnum] Status flags.
    # @param zone [Fixnum] Zone ID.
    # @param level [Fixnum] Level.
    # @param cls [Fixnum] Class.
    def initialize(guid, flags, note, status, zone, level, cls)
      @guid   = guid

      update(flags, note, status, zone, level, cls)
    end

    def update(flags, note, status, area, level, cls)
      @flags  = flags
      @note   = note
      @status = status
      @zone   = zone
      @level  = level
      @cls    = cls
    end
  end
end
