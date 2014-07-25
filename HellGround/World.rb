# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround
  module World
    # Server opcodes
    SMSG_AUTH_CHALLENGE           = 0x01EC
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
    SMSG_AUTH_RESPONSE            = 0x01EE
    SMSG_LOGIN_VERIFY_WORLD       = 0x0236
    SMSG_CHAT_PLAYER_NOT_FOUND    = 0x02A9
    SMSG_USERLIST_ADD             = 0x03EF
    SMSG_USERLIST_UPDATE          = 0x03F1

    # Client opcodes
    CMSG_AUTH_SESSION             = 0x01ED
    CMSG_CHAR_ENUM                = 0x0037
    CMSG_PLAYER_LOGIN             = 0x003D
    CMSG_LOGOUT_REQUEST           = 0x004B
    CMSG_NAME_QUERY               = 0x0050
    CMSG_ITEM_QUERY_SINGLE        = 0x0056
    CMSG_QUEST_QUERY              = 0x005C
    CMSG_WHO                      = 0x0062
    CMSG_CONTACT_LIST             = 0x0066
    CMSG_ADD_FRIEND               = 0x0069
    CMSG_DEL_FRIEND               = 0x006A
    CMSG_ADD_IGNORE               = 0x006C
    CMSG_DEL_IGNORE               = 0x006D
    CMSG_GUILD_ROSTER             = 0x0089
    CMSG_MESSAGECHAT              = 0x0095
    CMSG_JOIN_CHANNEL             = 0x0097
    CMSG_LEAVE_CHANNEL            = 0x0098
    CMSG_CHANNEL_LIST             = 0x009A
    CMSG_EMOTE                    = 0x0102
    CMSG_TEXT_EMOTE               = 0x0104
    CMSG_ITEM_NAME_QUERY          = 0x02C4

    class Connection < EM::Connection
      class Crypto
        CRYPTO_SEED = 0x38A78315F8922530719867B18C04E2AA

        def initialize(key)
          @send_i = @send_j = @recv_i = @recv_j = 0

          seed    = ['%016x' % CRYPTO_SEED].pack('H*')
          digest  = OpenSSL::Digest.new('sha1')
          @key    = OpenSSL::HMAC.digest(digest, seed, key.hexpack)

          raise StandardError, "Wrong key length" unless @key.length == 20
        end

        def decrypt(data)
          ret = []

          data.each_byte do |b|
            @recv_i %= @key.length
            x = (b - @recv_j) ^ @key[@recv_i].ord
            @recv_i += 1
            @recv_j = b
            ret << x
          end

          ret.pack('c*')
        end

        def encrypt(data)
          ret = []

          data.each_byte do |b|
            @send_i %= @key.length
            x = (b ^ @key[@send_i].ord) + @send_j
            @send_i += 1
            @send_j = x
            ret << x
          end

          ret.pack('c*')
        end
      end

      include Utils

      def initialize(username, key)
        @key      = key
        @username = username
      end

      def post_init
        puts "World connection opened."
      end

      def receive_data(data)
        pk = Packet.new(data)
        pk[0..3] = @crypto.decrypt pk[0..3] unless @crypto.nil?

        if VERBOSE
          puts "Recv: #{pk}"
          pk.data.hexdump
        end

        size  = pk.size16
        cmd   = pk.uint16

        handler = SMSG_HANDLERS[cmd]
        method(handler).call(pk) if handler
      rescue AuthError => e
        puts "Authentication error: #{e.message}."
        stop!
      # rescue => e
        # puts "#{e.message}."
        # stop!
      end

      def send_data(pk)
        if VERBOSE
          puts "Send: #{pk}"
          pk.data.hexdump
        end

        pk[0..5] = @crypto.encrypt pk[0..5] unless @crypto.nil?

        super(pk.data)
      end

      def unbind
        puts "World connection closed."
        stop!
      end

      def stop!
        EM::stop_event_loop
      end

      #
      # Server packet handlers
      #

      def OnAuthChallenge(pk)
        raise MalformedPacketError unless pk.length == 8

        @server_seed = pk.uint32
        @client_seed = 0xBB40E64D
        @digest = sha1(@username + (0).hexpack(4) + @client_seed.hexpack(4) +
                       @server_seed.hexpack(4) + @key.hexpack(40))

        send_data ClientAuthSession.new(@username, @client_seed, @digest)

        @crypto = Crypto.new(@key)
      end

      def OnAuthResponse(pk)
        raise AuthError, "Server authentication response error" unless pk.uint8 == 0x0C

        send_data ClientCharEnum.new
      end

      SMSG_HANDLERS = {
        SMSG_AUTH_CHALLENGE   => :OnAuthChallenge,
        SMSG_AUTH_RESPONSE    => :OnAuthResponse,
      }
    end

    #
    # Client packet handlers
    #

    class ClientAuthSession < Packet
      def initialize(username, seed, digest)
        super()

        self.size16 = username.length + 37  # size
        self.uint32 = CMSG_AUTH_SESSION     # type

        self.uint32 = 8606                  # build
        self.uint32 = 0                     # unknown
        self.str    = username              # account
        self.uint32 = seed                  # seed
        self.raw    = digest.hexpack(20)    # digest

        raise PacketLengthError unless length == username.length + 39
      end
    end

    class ClientCharEnum < Packet
      def initialize
        super()

        self.size16 = 4                     # size
        self.uint32 = CMSG_CHAR_ENUM        # type

        raise PacketLengthError unless length == 6
      end
    end

    class AuthError < StandardError; end
  end
end
