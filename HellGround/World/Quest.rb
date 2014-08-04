# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Quest object.
  class Quest
    attr_reader :id, :name

    # Returns quest by ID.
    # @param id [Fixnum] Quest ID.
    # @yield [Quest] Quest if found.
    # @return [Quest|Nil] Quest if found.
    def self.find(id)
      quest = @@quests[id]
      yield quest if block_given? && !quest.nil?
      quest
    end

    # @param id [Fixnum] ID.
    # @param name [String] Name.
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
