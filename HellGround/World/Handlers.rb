# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  module Handlers
    # Server packet handlers
    #
    # All server packets begin with 4 byte header consisting of:
    #   uint16 - packet size (big endian)
    #   uint16 - opcode number (little endian)
    #
    # Headers after SMSG_AUTH_CHALLENGE packet are encrypted. Packet contents
    # are not encrypted. All numeric data is little endian. Only the packet
    # size field of the header is sent as big endian.

    def SMSG_AUTH_CHALLENGE(pk)
      raise MalformedPacketError unless pk.length == 8

      @server_seed = pk.uint32
      @client_seed = 0xBB40E64D
      @digest = sha1(@username + (0).hexpack(4) + @client_seed.hexpack(4) +
                     @server_seed.hexpack(4) + @key.hexpack(40))

      send_data ClientAuthSession.new(@username, @client_seed, @digest)

      @crypto = Crypto.new(@key)
    end

    def SMSG_AUTH_RESPONSE(pk)
      raise AuthError, "Server authentication response error" unless pk.uint8 == 0x0C

      send_data ClientCharEnum.new
    end

    def SMSG_CHAR_ENUM(pk)
      @chars = []

      num = pk.uint8

      num.times do
        guid  = pk.uint64
        name  = pk.str
        race  = pk.uint8
        cls   = pk.uint8
        level = pk.skip(6).uint8
        pk.skip(221) # location, pet information, inventory data

        @chars << Player.new(guid, name, level, race, cls)
      end

      if HellGround::CHAR
        char = @chars.select { |char| char.name == HellGround::CHAR }.first

        if char
          @player = char
          @chars = nil

          puts "Logging in as #{char.name}."
          send_data ClientPlayerLogin.new(char)
        end
      else
        puts "Select character:"
        @chars.each { |char| puts " - #{char}" }
      end
    end

    def SMSG_MESSAGECHAT(pk)
      msg = ChatMessage.new(type: pk.uint8, lang: pk.uint32, guid: pk.uint64,
        lang2: pk.uint32, guid2: pk.uint64, len: pk.uint32, msg: pk.str, tag: pk.uint8)

      puts "Message: #{msg}"
    end

    def SMSG_MOTD(pk)
      num = pk.uint32

      num.times do
        puts "[MOTD] #{pk.str}"
      end
    end

    def SMSG_NOTIFICATION(pk)
      puts "[Notification] #{pk.str}"
    end
  end
end
