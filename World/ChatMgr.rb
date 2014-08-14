# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Chat manager.
  class ChatMgr
    # @param owner [#send_data] Owner object.
    def initialize(owner)
      @owner = owner

      @channels = []
      @queue = []
    end

    # Informs chat manager about new character. Flushes messages sent by that character.
    # @param char [Character] Character object.
    def introduce(char)
      @queue.select { |msg| msg.guid == char.guid }.each { |msg| @owner.notify :message_received, msg }
    end

    # Joins a channel.
    # @param channel [String] Channel name.
    def join(channel)
      return unless @channels.count < 20

      @channels.push channel
      @owner.send_data Packets::ClientJoinChannel.new(@channels.count + 2, channel)
    end

    # Leaves a channel.
    # @param channel [String] Channel name.
    def leave(channel)
      index = @channels.index(channel)

      return unless index

      @owner.send_data Packets::ClientLeaveChannel.new(index + 2, channel)
      @channels[index] = nil
    end

    # Displays chat message if the author is known. Enqueues the message and
    # queries the server for the client name otherwise.
    def receive(msg)
      return if msg.lang == ChatMessage::LANG_ADDON

      if Character.find(msg.guid) || msg.guid == 0
        @owner.notify :message_received, msg
      else
        @queue.push msg
        @owner.send_data Packets::ClientNameQuery.new(msg.guid)
      end
    end

    # Sends a chat message.
    # @param msg [ChatMessage] Message to send.
    def send(msg)
      @owner.send_data Packets::ClientChatMessage.new(msg)
      @owner.notify :message_sent, msg
    end
  end
end
