# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Server packet handlers.
  #
  # All server packets begin with 4 byte header consisting of:
  #   uint16 - packet size (big endian)
  #   uint16 - opcode number (little endian)
  #
  # Headers after +SMSG_AUTH_CHALLENGE+ packet are encrypted. Packet contents
  # are not encrypted. All numeric data is little endian. Only the packet
  # size field of the header is sent as big endian.
  module Handlers
    def SMSG_AUTH_CHALLENGE(pk)
      raise Packet::MalformedError unless pk.length == 8

      @server_seed = pk.uint32
      @client_seed = 0xBB40E64D
      @digest = sha1(@username + (0).hexpack(4) + @client_seed.hexpack(4) +
                     @server_seed.hexpack(4) + @key.hexpack(40))

      send_data Packets::ClientAuthSession.new(@username, @client_seed, @digest)

      @crypto = CryptoMgr.new(@key)
    end

    def SMSG_AUTH_RESPONSE(pk)
      raise AuthError, "Server authentication response error" unless pk.uint8 == 0x0C

      send_data Packets::ClientCharEnum.new
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
        pk.skip(221) # location, pet info, inventory data

        @chars << Player.new(guid, name, level, race, cls)
      end

      if HellGround::CHAR
        char = @chars.select { |char| char.name == HellGround::CHAR }.first

        if char
          @player = char

          puts "Logging in as #{char.name}."
          send_data Packets::ClientPlayerLogin.new(char)
        end
      else
        puts "Select character:"
        @chars.each { |char| puts " > #{char}" }
      end
    end

    def SMSG_CHAT_PLAYER_NOT_FOUND(pk)
      puts "Player #{pk.str} not found."
    end

    def SMSG_CONTACT_LIST(pk)
      pk.skip(4).uint32.times do
        guid  = pk.uint64
        flags = pk.uint32
        note  = pk.str

        if flags & SocialInfo::SOCIAL_FLAG_FRIEND > 0
          status = pk.uint8

          unless status == SocialInfo::FRIEND_STATUS_OFFLINE
            area  = pk.uint32
            level = pk.uint32
            cls   = pk.uint32
          end
        end

        social = @social.find(guid)

        if social
          social.update(flags, note, status, area, level, cls)
        else
          @social.introduce SocialInfo.new(guid, flags, note, status, area, level, cls)
        end
      end
    end

    def SMSG_GUILD_ROSTER(pk)
      num   = pk.uint32
      motd  = pk.str
      ginfo = pk.str

      pk.uint32.times { pk.skip 56 } # rank info

      num.times do
        guid  = pk.uint64
        online = pk.uint8
        name  = pk.str
        rank  = pk.uint32
        level = pk.uint8
        cls   = pk.uint8
        zone  = pk.skip(1).uint32
        offline_time = pk.float * 86400 if online == 0
        note  = pk.str
        onote = pk.str

        member = @guild.find(guid)

        if member
          member.update(online, rank, level, zone, offline_time, note, onote)
        else
          @guild.introduce GuildMember.new(guid, name, nil, cls, online, rank, level, zone, offline_time, note, onote)
        end
      end

      puts 'Guild roster:'
      puts @guild
    end

    def SMSG_ITEM_QUERY_SINGLE_RESPONSE(pk)
      id    = pk.uint32
      return if id & Item::INVALID_FLAG > 0
      name  = pk.skip(12).str

      Item.new(id, name)
    end

    def SMSG_LOGIN_VERIFY_WORLD(pk)
      puts "Login successful."

      send_data Packets::ClientGuildRoster.new
      @chat.join "world"
    end

    def SMSG_LOGOUT_COMPLETE(pk)
      @player = nil
      puts "Logout successful."

      send_data Packets::ClientCharEnum.new
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
      chan  = pk.str if type == ChatMessage::CHAT_MSG_CHANNEL
      guid2 = pk.uint64
      len   = pk.uint32
      text  = pk.str
      tag   = pk.uint8

      @chat.receive ChatMessage.new(type, lang, guid, text, chan)
    end

    def SMSG_MOTD(pk)
      pk.uint32.times { puts "[MOTD] #{pk.str}" }
    end

    def SMSG_NAME_QUERY_RESPONSE(pk)
      guid  = pk.uint64
      name  = pk.str
      race  = pk.skip(1).uint32
      cls   = pk.uint32

      @chat.introduce Character.new(guid, name, race, cls)
    end

    def SMSG_NOTIFICATION(pk)
      puts "[Notification] #{pk.str}"
    end
  end
end
