# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::Callbacks
  def self.extended(obj)
    obj.callbacks = {}
  end

  # Registers handler for specified symbol.
  # @param syms [Splat] Array of event symbols.
  # @param block [Block] Handler proc.
  def on(*syms, &block)
    syms.each { |sym| @callbacks[sym] = block }
  end

  # Notifies the handler about an event.
  # @param sym [Symbol] Event symbol.
  # @param args [Splat] Handler parameters.
  def notify(sym, *args)
    @callbacks[sym].call(*args) unless @callbacks[sym].nil?
  end
end
