# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Client packet handlers
  #
  # All client packets begin with 6 byte header consisting of:
  #   uint16 - packet size (big endian)
  #   uint32 - opcode number (little endian)
  #
  # Headers after SMSG_AUTH_CHALLENGE packet are encrypted. Packet contents
  # are not encrypted. All numeric data is little endian. Only the packet
  # size field of the header is sent as big endian.

  class ClientAuthSession < Packet
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

  class ClientCharEnum < Packet
    def initialize
      super()

      self.size16 = 4
      self.uint32 = CMSG::CMSG_CHAR_ENUM
    end
  end

  class ClientPlayerLogin < Packet
    def initialize(char)
      super()

      self.size16 = 12
      self.uint32 = CMSG::CMSG_PLAYER_LOGIN

      self.uint64 = char.guid
    end
  end

  class ClientLogoutRequest < Packet
    def initialize
      super()

      self.size16 = 4
      self.uint32 = CMSG::CMSG_LOGOUT_REQUEST
    end
  end

  class ClientNameQuery < Packet
    def initialize(guid)
      super()

      self.size16 = 12
      self.uint32 = CMSG::CMSG_NAME_QUERY

      self.uint64 = guid
    end
  end

  class ClientItemQuery < Packet
    def initialize(id)
      super()

      self.size16 = 8
      self.uint32 = CMSG::CMSG_ITEM_QUERY_SINGLE

      self.uint32 = id
    end
  end

  class ClientQuestQuery < Packet
    def initialize(id)
      super()

      self.size16 = 8
      self.uint32 = CMSG::CMSG_QUEST_QUERY

      self.uint32 = id
    end
  end

  class ClientWhoQuery < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_WHO
    end
  end

  class ClientContactList < Packet
    def initialize
      super()

      self.size16 = 8
      self.uint32 = CMSG::CMSG_CONTACT_LIST

      self.uint32 = 0
    end
  end

  class ClientAddFriend < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_ADD_FRIEND
    end
  end

  class ClientDeleteFriend < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_DEL_FRIEND
    end
  end

  class ClientAddIgnore < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_ADD_IGNORE
    end
  end

  class ClientDeleteIgnore < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_DEL_IGNORE
    end
  end

  class ClientGuildRoster < Packet
    def initialize
      super()

      self.size16 = 4
      self.uint32 = CMSG::CMSG_GUILD_ROSTER
    end
  end

  class ClientChatMessage < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_MESSAGECHAT
    end
  end

  class ClientJoinChannel < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_JOIN_CHANNEL
    end
  end

  class ClientLeaveChannel < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_LEAVE_CHANNEL
    end
  end

  class ClientChannelList < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_CHANNEL_LIST
    end
  end

  class ClientEmote < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_EMOTE
    end
  end

  class ClientTextEmote < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_TEXT_EMOTE
    end
  end

  class ClientItemNameQuery < Packet
    def initialize
      super()

      self.size16 = 000
      self.uint32 = CMSG::CMSG_ITEM_NAME_QUERY
    end
  end
end
