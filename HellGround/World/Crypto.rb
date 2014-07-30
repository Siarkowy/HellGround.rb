# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::World
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
end
