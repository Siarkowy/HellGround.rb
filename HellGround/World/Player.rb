# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  class Player
    attr_reader :guid, :name, :level, :race, :cls

    Races = [:Unused, :Human, :Orc, :Dwarf, :"Night Elf", :Undead, :Tauren,
      :Gnome, :Troll, :Goblin, :"Blood Elf", :Draenei]

    Classes = [:Unused, :Warrior, :Paladin, :Hunter, :Rogue, :Priest,
      :"Death Knight", :Shaman, :Mage, :Warlock, :Unused, :Druid]

    def initialize(guid, name, level, race, cls)
      @guid   = guid
      @name   = name
      @level  = level
      @race   = race
      @cls    = cls
    end

    def to_s
      "#{@name}, level #{@level} #{Races[@race]} #{Classes[@cls]}"
    end
  end
end
