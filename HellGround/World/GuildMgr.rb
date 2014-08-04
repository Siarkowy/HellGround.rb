# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Guild manager for handling guild related stuff.
  class GuildMgr
    STATUS_ONLINE = 0x1

    # @param owner [Object] Owner.
    def initialize(owner)
      @owner = owner
      @roster = {}
    end

    # Returns guild member by GUID.
    # @param guid [Fixnum] Character GUID.
    # @return [GuildMember|nil] Guild member if found.
    def find(guid)
      @roster[guid]
    end

    # Introduces a new guild member to guild manager.
    # @param member [GuildMember] New guild member.
    def introduce(member)
      @roster[member.guid] = member
    end

    # Returns guild roster, filtered to only include online characters.
    # @return [Hash<Fixnum, GuildMember>] Guild roster (online only).
    def online
      @roster.select { |guid, char| char.online == STATUS_ONLINE }
    end

    # Returns guild roster.
    # @return [Hash<Fixnum, GuildMember>] Guild roster.
    def roster
      @roster
    end

    def to_s
      @roster.map { |guid, char| char.to_s }.join("\n")
    end
  end
end
