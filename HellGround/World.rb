# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround
  module World
    SMSG_CHAR_ENUM                = 0x003B
    SMSG_NAME_QUERY_RESPONSE      = 0x0051
    SMSG_CONTACT_LIST             = 0x0067
    SMSG_FRIEND_STATUS            = 0x0068
    SMSG_GUILD_ROSTER             = 0x008A
    SMSG_GUILD_EVENT              = 0x0092
    SMSG_MESSAGECHAT              = 0x0096
    SMSG_CHANNEL_NOTIFY           = 0x0099
    SMSG_CHANNEL_LIST             = 0x009B
    SMSG_NOTIFICATION             = 0x01CB
    SMSG_AUTH_CHALLENGE           = 0x01EC
    CMSG_AUTH_SESSION             = 0x01ED
    SMSG_AUTH_RESPONSE            = 0x01EE
    SMSG_LOGIN_VERIFY_WORLD       = 0x0236
    SMSG_CHAT_PLAYER_NOT_FOUND    = 0x02A9
    SMSG_USERLIST_ADD             = 0x03EF
    SMSG_USERLIST_UPDATE          = 0x03F1

    class Connection < EM::Connection
      def initialize(username, key)
        @username = username
        @key = key
      end

      def post_init
        # send_data Packet.new
      end

      def receive_data(data)
        if VERBOSE
          puts "Recv: length #{data.length}"
          data.hexdump
        end

        pk = Packet.new(data)

        handler = SMSG_HANDLERS[pk.skip(2).uint16]
        self.method(handler).call(pk) if handler
      rescue AuthError => e
        puts "Authentication error: #{e.message}."
        stop!
      rescue => e
        puts "#{e.message}."
        stop!
      end

      def send_data(pk)
        if VERBOSE
          puts "Send:"
          pk.dump
        end

        super(pk.data)
      end

      def unbind
        puts "World connection closed."
        stop!
      end

      def stop!
        EM::stop_event_loop
      end

      def OnAuthChallenge(pk)
        raise ArgumentError, "PacketMissing" unless pk
        raise MalformedPacketError unless pk.length == 8

        @seed = pk.uint32

        send_data ClientAuthSession.new
      end

      SMSG_HANDLERS = {
        SMSG_AUTH_CHALLENGE   => :OnAuthChallenge
      }
    end

    class ClientAuthSession < Packet
      def initialize
        super()

        self.uint16 = @username.length + 37 # size
        self.uint32 = CMSG_AUTH_SESSION     # type
        self.uint32 = 8606                  # build
        self.str    = @username             # account
        self.uint32 = 0                     # unknown
      # self.uint32 = ?                     # seed
      # self.raw    = ?                     # digest
      end
    end

    class AuthError < StandardError; end
  end
end
