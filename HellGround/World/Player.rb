# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  class Player < Character
    attr_reader :level

    def initialize(guid, name, level, race, cls)
      super(guid, name, race, cls)
      @level  = level
    end

    def to_s
      "#{@name}, level #{@level} #{Races[@race]} #{Classes[@cls]}"
    end
  end
end
