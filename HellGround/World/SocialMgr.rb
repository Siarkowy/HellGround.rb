# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Social manager.
  class SocialMgr
    # @param owner [#send_data] Owner.
    def initialize(owner)
      @owner = owner
      @data = {}
    end

    # Returns social data.
    # @return [Hash<Fixnum, SocialInfo>] Social data.
    def data
      @data
    end

    # Returns social info object by GUID.
    # @param guid [Fixnum] Social GUID.
    # @return [SocialInfo|Nil] Social info if found.
    def find(guid, &block)
      social = @data[guid]
      yield social if block_given? && !social.nil?
      social
    end

    def friend(name)
      # return if @data.select { |guid, social| social.to_char.name == name }.first
      @owner.send_data Packets::ClientAddFriend.new(name)
    end

    # Returns friends.
    # @return [Hash<Fixnum, SocialInfo>] Friend info.
    def friends
      @data.select { |guid, social| social.flags & SocialInfo::SOCIAL_FLAG_FRIEND > 0 }
    end

    def ignore(name)
      # return if @data.select { |guid, social| social.to_char.name == name }.first
      @owner.send_data Packets::ClientAddIgnore.new(name)
    end

    # Returns ignores.
    # @return [Hash<Fixnum, SocialInfo>] Ignore info.
    def ignores
      @data.select { |guid, social| social.flags & SocialInfo::SOCIAL_FLAG_FRIEND == 0 }
    end

    # Introduces new social object to social manager.
    # @param social [SocialInfo] Social info object.
    def introduce(social)
      @data[social.guid] = social
    end

    # Removes a friend.
    # @param name [String] Character name.
    def unfriend(name)
      del_guid, _ = friends.select { |guid, social| social.to_char.name == name }.first
      return unless del_guid
      @data.reject! { |guid, social| guid == del_guid }
      @owner.send_data Packets::ClientDeleteFriend.new(del_guid)
    end

    # Removes an ignore.
    # @param name [String] Character name.
    def unignore(name)
      del_guid, _ = ignores.select { |guid, social| social.to_char.name == name }.first
      return unless del_guid
      @data.reject! { |guid, social| guid == del_guid }
      @owner.send_data Packets::ClientDeleteIgnore.new(del_guid)
    end
  end
end
