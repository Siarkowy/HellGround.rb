# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Guild member object.
  class GuildMember
    attr_reader :guid, :online, :rank, :level, :zone, :offline_time, :note, :onote

    # @param guid [Fixnum] Character GUID.
    def initialize(guid, *args)
      @guid = guid
      update(*args)
    end

    # Updates member with data from the SMSG_GUILD_ROSTER packet.
    # @param online [Fixnum] Online status.
    # @param rank [Fixnum] Rank ID.
    # @param level [Fixnum] Level.
    # @param zone [Fixnum] Zone ID.
    # @param offline_time [Float] Offline time as a fraction of day (86400 sec).
    # @param note [String] Player note.
    # @param onote [String] Officer note.
    def update(online, rank, level, zone, offline_time, note, onote)
      @online = online
      @rank   = rank
      @level  = level
      @zone   = zone
      @offline_time = offline_time
      @note   = note.empty? ? nil : note
      @onote  = onote.empty? ? nil : onote
    end

    # Returns character object.
    # @return [Character] Character.
    def to_char
      Character.find(@guid)
    end

    def to_s
      char = to_char

      format '%-16s %2d %-10s %-22.22s %-22.22s %s', char.name, @level,
        Character::Classes[char.cls], @note, @onote, @online == 1 ? 'on' : ''
    end
  end
end
