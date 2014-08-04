# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
  # Social manager.
  class SocialMgr
    # @param owner [Object] Owner.
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
    def find(guid)
      @data[guid]
    end

    # Returns friends.
    # @return [Hash<Fixnum, SocialInfo>] Friend info.
    def friends
      @data.select { |guid, char| char.flags & SocialInfo::SOCIAL_FLAG_FRIEND > 0 }
    end

    # Returns ignores.
    # @return [Hash<Fixnum, SocialInfo>] Ignore info.
    def ignores
      @data.select { |guid, char| char.flags & SocialInfo::SOCIAL_FLAG_FRIEND == 0 }
    end

    # Introduces new social object to social manager.
    # @param social [SocialInfo] Social info object.
    def introduce(social)
      puts 'introduce'
      @data[social.guid] = social
    end
  end
end
