# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Character object.
  class Character
    Races = [:Unused, :Human, :Orc, :Dwarf, :"Night Elf", :Undead, :Tauren,
      :Gnome, :Troll, :Goblin, :"Blood Elf", :Draenei]

    Classes = [:Unused, :Warrior, :Paladin, :Hunter, :Rogue, :Priest,
      :"Death Knight", :Shaman, :Mage, :Warlock, :Unused, :Druid]

    attr_reader :guid, :name, :race, :cls

    # Returns character by GUID if found.
    # @param guid [Fixnum] Character GUID.
    # @return [Character|Nil] Character object.
    def self.find(guid)
      @@chars[guid]
    end

    # @param guid [Fixnum] GUID.
    # @param name [String] Name.
    # @param race [Fixnum] Race.
    # @param cls [Fixnum] Class.
    def initialize(guid, name, race, cls)
      @guid   = guid
      @name   = name
      @race   = race
      @cls    = cls

      @@chars[@guid] = self
    end

    def to_s
      "#{@name}, #{Races[@race] || 'Unknown'} #{Classes[@cls] || 'Unknown'}"
    end

    private

    @@chars = {}
  end
end
