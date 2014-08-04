# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Player character. Characters you can log into the game with.
  class Player < Character
    attr_reader :level, :lang

    # @param guid [Fixnum] Character GUID.
    # @param name [String] Name.
    # @param level [Fixnum] Level.
    # @param race [Fixnum] Race.
    # @param cls [Fixnum] Class.
    def initialize(guid, name, level, race, cls)
      super(guid, name, race, cls)

      @lang   = is_horde? ? ChatMessage::LANG_ORCISH : ChatMessage::LANG_COMMON
      @level  = level
    end

    def is_horde?
      (1 << @race) & 1380 > 0
    end

    def to_s
      "#{@name}, level #{@level} #{Races[@race]} #{Classes[@cls]}"
    end
  end
end
