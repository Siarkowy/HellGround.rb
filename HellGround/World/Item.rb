# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  class Item
    INVALID_FLAG = 0x80000000

    attr_reader :id, :name

    def self.find(id)
      item = @@items[id]
      yield item if block_given? && !item.nil?
      item
    end

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
