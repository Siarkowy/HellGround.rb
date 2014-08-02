# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  class Quest
    attr_reader :id, :name

    def self.find(id)
      quest = @@quests[id]
      yield quest if block_given? && !quest.nil?
      quest
    end

    def initialize(id, name)
      @id   = id
      @name = name

      @@quests[@id] = self
    end

    def to_s
      "[Quest: #{@name}]"
    end

    private

    @@quests = {}
  end
end
