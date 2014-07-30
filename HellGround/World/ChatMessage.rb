# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  class ChatMessage
    def initialize(args)
      @type = args[:type]
      @lang = args[:lang]
      @guid = args[:guid]
      @msg  = args[:msg]
    end

    def to_s
      @msg
    end
  end
end
