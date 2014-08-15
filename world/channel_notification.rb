# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  class ChannelNotification
    CHAT_JOINED_NOTICE                = 0x00
    CHAT_LEFT_NOTICE                  = 0x01
    CHAT_YOU_JOINED_NOTICE            = 0x02
    CHAT_YOU_LEFT_NOTICE              = 0x03
    CHAT_WRONG_PASSWORD_NOTICE        = 0x04
    CHAT_NOT_MEMBER_NOTICE            = 0x05
    CHAT_NOT_MODERATOR_NOTICE         = 0x06
    CHAT_PASSWORD_CHANGED_NOTICE      = 0x07
    CHAT_OWNER_CHANGED_NOTICE         = 0x08
    CHAT_PLAYER_NOT_FOUND_NOTICE      = 0x09
    CHAT_NOT_OWNER_NOTICE             = 0x0A
    CHAT_CHANNEL_OWNER_NOTICE         = 0x0B
    CHAT_MODE_CHANGE_NOTICE           = 0x0C
    CHAT_ANNOUNCEMENTS_ON_NOTICE      = 0x0D
    CHAT_ANNOUNCEMENTS_OFF_NOTICE     = 0x0E
    CHAT_MODERATION_ON_NOTICE         = 0x0F
    CHAT_MODERATION_OFF_NOTICE        = 0x10
    CHAT_MUTED_NOTICE                 = 0x11
    CHAT_PLAYER_KICKED_NOTICE         = 0x12
    CHAT_BANNED_NOTICE                = 0x13
    CHAT_PLAYER_BANNED_NOTICE         = 0x14
    CHAT_PLAYER_UNBANNED_NOTICE       = 0x15
    CHAT_PLAYER_NOT_BANNED_NOTICE     = 0x16
    CHAT_PLAYER_ALREADY_MEMBER_NOTICE = 0x17
    CHAT_INVITE_NOTICE                = 0x18
    CHAT_INVITE_WRONG_FACTION_NOTICE  = 0x19
    CHAT_WRONG_FACTION_NOTICE         = 0x1A
    CHAT_INVALID_NAME_NOTICE          = 0x1B
    CHAT_NOT_MODERATED_NOTICE         = 0x1C
    CHAT_PLAYER_INVITED_NOTICE        = 0x1D
    CHAT_PLAYER_INVITE_BANNED_NOTICE  = 0x1E
    CHAT_THROTTLED_NOTICE             = 0x1F
    CHAT_NOT_IN_AREA_NOTICE           = 0x20
    CHAT_NOT_IN_LFG_NOTICE            = 0x21
    CHAT_VOICE_ON_NOTICE              = 0x22
    CHAT_VOICE_OFF_NOTICE             = 0x23

    NotifyStrings = {
      CHAT_JOINED_NOTICE                => "%s joined channel.",
      CHAT_LEFT_NOTICE                  => "%s left channel.",
      CHAT_YOU_JOINED_NOTICE            => "Joined channel <%s>.",
      CHAT_YOU_LEFT_NOTICE              => "Left channel <%s>.",
      CHAT_WRONG_PASSWORD_NOTICE        => "Wrong password for <%s>.",
      CHAT_NOT_MEMBER_NOTICE            => "Not on channel <%s>.",
      CHAT_NOT_MODERATOR_NOTICE         => "Not a moderator of <%s>.",
      CHAT_PASSWORD_CHANGED_NOTICE      => "<%s> Password changed by %s.",
      CHAT_OWNER_CHANGED_NOTICE         => "<%s> Owner changed to %s.",
      CHAT_PLAYER_NOT_FOUND_NOTICE      => "<%s> Player %s was not found.",
      CHAT_NOT_OWNER_NOTICE             => "<%s> You are not the channel owner.",
      CHAT_CHANNEL_OWNER_NOTICE         => "<%s> Channel owner is %s.",
      CHAT_MODE_CHANGE_NOTICE           => "", # unused
      CHAT_ANNOUNCEMENTS_ON_NOTICE      => "<%s> Channel announcements enabled by %s.",
      CHAT_ANNOUNCEMENTS_OFF_NOTICE     => "<%s> Channel announcements disabled by %s.",
      CHAT_MODERATION_ON_NOTICE         => "<%s> Channel moderation enabled by %s.",
      CHAT_MODERATION_OFF_NOTICE        => "<%s> Channel moderation disabled by %s.",
      CHAT_MUTED_NOTICE                 => "<%s> You do not have permission to speak.",
      CHAT_PLAYER_KICKED_NOTICE         => "<%s> Player %s kicked by %s.",
      CHAT_BANNED_NOTICE                => "<%s> You are banned from that channel.",
      CHAT_PLAYER_BANNED_NOTICE         => "<%s> Player %s banned by %s.",
      CHAT_PLAYER_UNBANNED_NOTICE       => "<%s> Player %s unbanned by %s.",
      CHAT_PLAYER_NOT_BANNED_NOTICE     => "<%s> Player %s is not banned.",
      CHAT_PLAYER_ALREADY_MEMBER_NOTICE => "<%s> Player %s is already on the channel.",
      CHAT_INVITE_NOTICE                => "%2$s has invited you to join the channel <%1$s>.",
      CHAT_INVITE_WRONG_FACTION_NOTICE  => "Target is in the wrong alliance for %s.",
      CHAT_WRONG_FACTION_NOTICE         => "Wrong alliance for %s.",
      CHAT_INVALID_NAME_NOTICE          => "Invalid channel name.",
      CHAT_NOT_MODERATED_NOTICE         => "<%s> is not moderated.",
      CHAT_PLAYER_INVITED_NOTICE        => "<%s> You invited %s to join the channel.",
      CHAT_PLAYER_INVITE_BANNED_NOTICE  => "<%s> %s has been banned.",
      CHAT_THROTTLED_NOTICE             => "<%s> The number of messages that can be sent to this channel is limited, please wait to send another message.",
      CHAT_NOT_IN_AREA_NOTICE           => "<%s> You are not in the correct area for this channel.",
      CHAT_NOT_IN_LFG_NOTICE            => "<%s> You must be queued in looking for group before joining this channel.",
      CHAT_VOICE_ON_NOTICE              => "<%s> Channel voice enabled by %s.",
      CHAT_VOICE_OFF_NOTICE             => "<%s> Channel voice disabled by %s.",
    }

    def initialize(type, name, name2 = '')
      @type   = type
      @name   = name
      @name2  = name2
    end

    def to_s
      format NotifyStrings[@type], @name, @name2
    end
  end
end
