# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Player character. Characters you can log into the game with.
  class Player
    attr_reader :guid, :level, :lang

    # @param guid [Fixnum] Character GUID.
    # @param name [String] Name.
    # @param level [Fixnum] Level.
    # @param race [Fixnum] Race.
    # @param cls [Fixnum] Class.
    def initialize(guid, name, level, race, cls)
      Character.new(guid, name, race, cls) unless Character.find(guid)

      @guid   = guid
      @lang   = is_horde? ? ChatMessage::LANG_ORCISH : ChatMessage::LANG_COMMON
      @level  = level
    end

    # Returns true if player is a Horde character.
    # @return [Boolean] Whether player is a Horde character.
    def is_horde?
      (1 << to_char.race) & 1380 > 0
    end

    # Returns character object.
    # @return [Character] Character.
    def to_char
      Character.find(@guid)
    end

    def to_s
      char = to_char

      "#{char.name}, level #{@level} #{Character::Races[char.race]} #{Character::Classes[char.cls]}"
    end
  end
end
