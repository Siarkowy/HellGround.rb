# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Guild member object.
  class GuildMember < Character
    attr_reader :online, :rank, :level, :zone, :offline_time, :note, :onote

    def initialize(guid, name, race, cls, *args)
      super(guid, name, race, cls)
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

    def to_s
      format '%-16s %2d %-10s %-22.22s %-22.22s %s', @name, @level, Classes[@cls], @note,
        @onote, @online == 1 ? 'on' : ''
    end
  end
end
