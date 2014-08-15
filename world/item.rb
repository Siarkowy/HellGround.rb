# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Item object.
  class Item
    INVALID_FLAG = 0x80000000

    attr_reader :id, :name

    # Returns item by ID.
    # @param id [Fixnum] Item ID.
    # @yield [Item] Item if found.
    # @return [Item|Nil] Item if found.
    def self.find(id)
      item = @@items[id]
      yield item if block_given? && !item.nil?
      item
    end

    # @param id [Fixnum] ID.
    # @param name [String] Name.
    def initialize(id, name)
      @id   = id
      @name = name

      @@items[@id] = self
    end

    def to_s
      "[Item: #{@name}]"
    end

    private

    @@items = {}
  end
end
