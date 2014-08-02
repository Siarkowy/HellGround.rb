# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  class Character
    FRIEND_STATUS_OFFLINE   = 0x00
    FRIEND_STATUS_ONLINE    = 0x01
    FRIEND_STATUS_AFK       = 0x02
    FRIEND_STATUS_DND       = 0x04
    FRIEND_STATUS_RAF       = 0x08

    SOCIAL_FLAG_FRIEND      = 0x01

    Races = [:Unused, :Human, :Orc, :Dwarf, :"Night Elf", :Undead, :Tauren,
      :Gnome, :Troll, :Goblin, :"Blood Elf", :Draenei]

    Classes = [:Unused, :Warrior, :Paladin, :Hunter, :Rogue, :Priest,
      :"Death Knight", :Shaman, :Mage, :Warlock, :Unused, :Druid]

    attr_reader :guid, :name, :race, :cls

    def self.find(guid)
      char = @@chars[guid]
      yield char if block_given? && !char.nil?
      char
    end

    def initialize(guid, name, race, cls)
      @guid   = guid
      @name   = name
      @race   = race
      @cls    = cls

      @@chars[@guid] = self
    end

    def to_s
      "#{@name}, #{Races[@race]} #{Classes[@cls]}"
    end

    private

    @@chars = {}
  end
end
