# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

# Client packets.
#
# All client packets begin with a 6 byte header consisting of:
#   uint16 - packet size (big endian)
#   uint32 - opcode number (little endian)
#
# Headers after +SMSG_AUTH_CHALLENGE+ packet are encrypted. Packet contents
# are not encrypted. All numeric data is little endian. Only the packet
# size field of the header is sent as big endian.
module HellGround::World::Packets
  # Allowed opcodes for client packets.
  module CMSG
    CMSG_AUTH_SESSION           = 0x01ED
    CMSG_CHAR_ENUM              = 0x0037
    CMSG_PLAYER_LOGIN           = 0x003D
    CMSG_LOGOUT_REQUEST         = 0x004B
    CMSG_NAME_QUERY             = 0x0050
    CMSG_ITEM_QUERY_SINGLE      = 0x0056
    CMSG_QUEST_QUERY            = 0x005C
    CMSG_WHO                    = 0x0062
    CMSG_CONTACT_LIST           = 0x0066
    CMSG_ADD_FRIEND             = 0x0069
    CMSG_DEL_FRIEND             = 0x006A
    CMSG_ADD_IGNORE             = 0x006C
    CMSG_DEL_IGNORE             = 0x006D
    CMSG_GUILD_ROSTER           = 0x0089
    CMSG_MESSAGECHAT            = 0x0095
    CMSG_JOIN_CHANNEL           = 0x0097
    CMSG_LEAVE_CHANNEL          = 0x0098
    CMSG_CHANNEL_LIST           = 0x009A
    CMSG_EMOTE                  = 0x0102
    CMSG_TEXT_EMOTE             = 0x0104
    CMSG_ITEM_NAME_QUERY        = 0x02C4
  end

  Packet = HellGround::World::Packet

  # Authentication session packet. Server should respond with +SMSG_AUTH_RESPONSE+ packet.
  class ClientAuthSession < Packet
    # @param username [String] Account name.
    # @param seed [Fixnum] Client seed.
    # @param digest [Fixnum] Client digest (see +SMSG_AUTH_CHALLENGE+ handler).
    def initialize(username, seed, digest)
      super()

      self.size16 = username.length + 37
      self.uint32 = CMSG::CMSG_AUTH_SESSION

      self.uint32 = 8606                  # build
      self.uint32 = 0                     # unknown
      self.str    = username              # account
      self.uint32 = seed                  # seed
      self.raw    = digest.hexpack(20)    # digest
    end
  end

  # Character enumerate packet. Server should respond with +SMSG_CHAR_ENUM+ packet.
  class ClientCharEnum < Packet
    def initialize
      super()

      self.size16 = 4
      self.uint32 = CMSG::CMSG_CHAR_ENUM
    end
  end

  # Login packet. Login is successful if server responds with +SMSG_LOGIN_VERIFY_WORLD+ packet.
  class ClientPlayerLogin < Packet
    # @param player [Player] Player object.
    def initialize(player)
      super()

      self.size16 = 12
      self.uint32 = CMSG::CMSG_PLAYER_LOGIN

      self.uint64 = player.guid
    end
  end

  # Logout request packet. Logout is successful if server responds with +SMSG_LOGOUT_COMPLETE+ packet.
  class ClientLogoutRequest < Packet
    def initialize
      super()

      self.size16 = 4
      self.uint32 = CMSG::CMSG_LOGOUT_REQUEST
    end
  end

  # GUID lookup packet. Server should respond with +SMSG_NAME_QUERY_RESPONSE+ packet.
  class ClientNameQuery < Packet
    # @param guid [Fixnum] Character GUID.
    def initialize(guid)
      super()

      self.size16 = 12
      self.uint32 = CMSG::CMSG_NAME_QUERY

      self.uint64 = guid
    end
  end

  # Item lookup packet. Server should respond with +SMSG_ITEM_QUERY_SINGLE_RESPONSE+ packet.
  class ClientItemQuery < Packet
    # @param id [Fixnum] Item ID.
    def initialize(id)
      super()

      self.size16 = 8
      self.uint32 = CMSG::CMSG_ITEM_QUERY_SINGLE

      self.uint32 = id
    end
  end

  # Quest lookup packet. Server should respond with +SMSG_QUEST_QUERY_RESPONSE+ packet.
  class ClientQuestQuery < Packet
    # @param id [Fixnum] Quest ID.
    def initialize(id)
      super()

      self.size16 = 8
      self.uint32 = CMSG::CMSG_QUEST_QUERY

      self.uint32 = id
    end
  end

  class ClientWhoQuery < Packet
    def initialize
      raise NotImplementedError

      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_WHO
    end
  end

  # Contact list query packet. Server should respond with +SMSG_CONTACT_LIST+ packet.
  class ClientContactList < Packet
    def initialize
      super()

      self.size16 = 8
      self.uint32 = CMSG::CMSG_CONTACT_LIST

      self.uint32 = 0
    end
  end

  # Add friend packet.
  class ClientAddFriend < Packet
    # @param name [String] Name.
    # @param note [String] Note.
    def initialize(name, note = '')
      super()

      self.size16 = 4 + name.length.succ + note.length.succ
      self.uint32 = CMSG::CMSG_ADD_FRIEND

      self.str    = name
      self.str    = note
    end
  end

  # Delete friend packet.
  class ClientDeleteFriend < Packet
    # @param guid [Fixnum] Character GUID.
    def initialize(guid)
      super()

      self.size16 = 12
      self.uint32 = CMSG::CMSG_DEL_FRIEND

      self.uint64 = guid
    end
  end

  # Add ignore packet.
  class ClientAddIgnore < Packet
    # @param name [String] Name.
    def initialize(name)
      super()

      self.size16 = 4 + name.length.succ
      self.uint32 = CMSG::CMSG_ADD_IGNORE

      self.str    = name
    end
  end

  # Delete ignore packet.
  class ClientDeleteIgnore < Packet
    # @param guid [Fixnum] Character GUID.
    def initialize(guid)
      super()

      self.size16 = 12
      self.uint32 = CMSG::CMSG_DEL_IGNORE

      self.uint64 = guid
    end
  end

  # Guild roster query packet. Server should respond with +SMSG_GUILD_ROSTER+ packet.
  class ClientGuildRoster < Packet
    def initialize
      super()

      self.size16 = 4
      self.uint32 = CMSG::CMSG_GUILD_ROSTER
    end
  end

  # Chat message packet.
  class ClientChatMessage < Packet
    ChatMessage = HellGround::World::ChatMessage

    # @param msg [ChatMessage] Chat message.
    def initialize(msg)
      super()

      self.size16 = 12 + (msg.to ? msg.to.length.succ : 0) + msg.text.length.succ
      self.uint32 = CMSG::CMSG_MESSAGECHAT

      self.uint32 = msg.type
      self.uint32 = msg.lang
      # Message target for whisper and channel messages:
      self.str    = msg.to if (1 << msg.type) & 0x20080 > 0
      self.str    = msg.text
    end
  end

  # Channel join packet.
  class ClientJoinChannel < Packet
    # @param id [Fixnum] Local ID.
    # @param name [String] Name.
    def initialize(id, name)
      super()

      self.size16 = 12 + name.length
      self.uint32 = CMSG::CMSG_JOIN_CHANNEL

      self.uint8  = id
      self.uint8  = 0
      self.uint32 = 0
      self.str    = name
      self.uint8  = 0
    end
  end

  # Channel leave packet.
  class ClientLeaveChannel < Packet
    # @param id [Fixnum] Local ID.
    # @param name [String] Name.
    def initialize(id, name)
      super()

      self.size16 = 8 + name.length.succ
      self.uint32 = CMSG::CMSG_LEAVE_CHANNEL

      self.uint32 = id
      self.str    = name
    end
  end

  class ClientChannelList < Packet
    def initialize
      raise NotImplementedError

      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_CHANNEL_LIST
    end
  end

  class ClientEmote < Packet
    def initialize
      raise NotImplementedError

      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_EMOTE
    end
  end

  class ClientTextEmote < Packet
    def initialize
      raise NotImplementedError

      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_TEXT_EMOTE
    end
  end

  class ClientItemNameQuery < Packet
    def initialize
      raise NotImplementedError

      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_ITEM_NAME_QUERY
    end
  end
end
