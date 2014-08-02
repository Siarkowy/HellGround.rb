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

          puts "Logging in as #{char.name}."
          send_data ClientPlayerLogin.new(char)
        end
      else
        puts "Select character:"
        @chars.each { |char| puts " > #{char}" }
      end
    end

    def SMSG_ITEM_QUERY_SINGLE_RESPONSE(pk)
      id    = pk.uint32
      return if id & Item::INVALID_FLAG > 0
      name  = pk.skip(12).str

      Item.new(id, name)
    end

    def SMSG_LOGIN_VERIFY_WORLD(pk)
      send_data ClientGuildRoster.new
    end

    def SMSG_LOGOUT_COMPLETE(pk)
      @player = nil
      puts "Logged out."
      @chars.each { |char| puts " > #{char}" }
    end

    def SMSG_QUEST_QUERY_RESPONSE(pk)
      id    = pk.uint32
      name  = pk.skip(168).str

      Quest.new(id, name)
    end

    def SMSG_MESSAGECHAT(pk)
      type  = pk.uint8
      lang  = pk.uint32
      guid  = pk.uint64
      lang2 = pk.uint32
      guid2 = pk.uint64
      len   = pk.uint32
      text  = pk.str
      tag   = pk.uint8

      msg = ChatMessage.new(type, lang, guid, text)

      if Character.find(guid)
        puts msg
      else
        @msg_queue ||= []
        @msg_queue.push msg
        send_data ClientNameQuery.new(guid)
      end
    end

    def SMSG_MOTD(pk)
      num = pk.uint32

      num.times do
        puts "[MOTD] #{pk.str}"
      end
    end

    def SMSG_NAME_QUERY_RESPONSE(pk)
      guid  = pk.uint64
      name  = pk.str
      race  = pk.skip(1).uint32
      cls   = pk.uint32

      Character.new(guid, name, race, cls)

      @msg_queue.select { |msg| msg.guid == guid }.each { |msg| puts msg } if @msg_queue
    end

    def SMSG_NOTIFICATION(pk)
      puts "[Notification] #{pk.str}"
    end
  end
end
