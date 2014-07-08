# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require 'digest/sha1'
require 'openssl'

module HellGround
  module Connection
    #
    # Server packet handlers
    #

    def OnLogonChallenge(pk)
      raise ArgumentError, "Packet missing" unless pk

      result = pk.skip(1).uint8
      raise StandardError, Auth::RESULT_STRING[result] unless result == Auth::RESULT_SUCCESS

      b = pk.hex(32)    # B
     _g = pk.uint8      # size of g
      g = pk.hex(_g)    # g
     _n = pk.uint8      # size of N
      n = pk.hex(_n)    # N
      salt = pk.hex(32) # s
      t = pk.hex(16)    # unknown
      f = pk.uint8      # flags

      raise MalformedPacketError, "Got wrong N from server" unless n == Auth::N
      raise MalformedPacketError, "Got wrong g from server" unless g == Auth::G

      k = 3
      i = sha1("#{@username}:#{@password}")       # i = H(C|:|P)
      x = sha1(salt.hexpack(32) + i.hexpack(20))  # x = H(salt|i)
      v = g.to_bn.mod_exp(x, n).to_i              # v = g ** x % N
     _a = rand_bytes(32)                          # a = rand()
      a = g.to_bn.mod_exp(_a, n).to_i             # A  = g ** a % N

      # check whether A % N == 0
      raise MalformedPacketError, "Public key equal zero" if a.to_bn.mod_exp(1, n) == 0

      # u = H(A|B)
      u = sha1(a.hexpack(32) + b.hexpack(32))

      # S = (B - k * g ** x % N) ** (a + u * x) % N
      s = (b - k * g.to_bn.mod_exp(x, n)).to_bn.mod_exp(_a + u * x, n).to_i

      even = ''
      odd = ''

      ['%064x' % s].pack('H*').split('').each_slice(2) { |e, o| even << e; odd << o }

      even = Digest::SHA1.digest(even.reverse).reverse
      odd = Digest::SHA1.digest(odd.reverse).reverse
      @key = even.split('').zip(odd.split('')).flatten.compact.join.unpack('H*').first.hex

      gnhash = Digest::SHA1.digest(n.hexpack(32)).reverse
      ghash = Digest::SHA1.digest(g.hexpack(1)).reverse
      (0..19).each { |i| gnhash[i] = (gnhash[i].ord ^ ghash[i].ord).chr }
      gnhash = gnhash.unpack('H*').first.hex

      userhash = sha1(@username)
      m1 = sha1(gnhash.hexpack(20) + userhash.hexpack(20) + salt.hexpack(32) +
           a.hexpack(32) + b.hexpack(32) + @key.hexpack(40))
      @m2 = sha1(a.hexpack(32) + m1.hexpack(20) + @key.hexpack(40))

      send_data Auth::ClientLogonProof.new(a, m1, Auth::CRC_HASH)
    end

    def sha1(str)
      Digest::SHA1.digest(str).reverse.unpack('H*').first.hex
    end

    def rand_bytes(num)
      OpenSSL::Random.random_bytes(32).unpack("H*").first.hex
    end

    def OnLogonProof(pk)
      raise ArgumentError, "Packet missing" unless pk

      result = pk.uint8
      raise AuthError, Auth::RESULT_STRING[result] unless result == Auth::RESULT_SUCCESS

      m2 = pk.hex(20)       # M2
      accFlags = pk.uint32  # account flags
      surveyId = pk.uint32  # survey id
      unkFlags = pk.uint16  # unknown flags

      close unless m2 == @m2 # check server key
      @m2 = nil

      puts "Authentication successful. Requesting realm list."

      send_data Auth::ClientRealmList.new
    end

    def OnRealmList(pk)
      raise ArgumentError, "Packet missing" unless pk

      @realms = []

      size = pk.uint16
      unused = pk.uint32
      num_realms = pk.uint16

      num_realms.times do
        type  = pk.uint8
        lock  = pk.uint8
        flags = pk.uint8
        name  = pk.str
        addr  = pk.str
        popul = pk.float
        chars = pk.uint8
        zone  = pk.uint8
        unk   = pk.uint8

        unless flags & Auth::REALM_FLAG_SPECIFYBUILD == 0
          maj = pk.uint8
          min = pk.uint8
          fix = pk.uint8
          build = pk.uint16
        end

        if flags & Auth::REALM_FLAG_SKIP == 0 # && lock == 0
          host, port = addr.split(':')
          puts "Discovered realm #{name} at #{addr}."
          @realms << [name, host, port.to_i]
        end
      end

      raise AuthError, "No on-line realm to connect found" if @realms.empty?

      # connect to the first available server
      name, host, port = @realms[0]
      puts "Connecting to world server #{name} at #{host}:#{port}."
      reconnect host, port
    end

    def OnOtherPacket(pk)
      raise UnsupportedPacketError, "Packet 0x#{pk.type.to_s(16)} of length #{pk.length}"
    end
  end

  class AuthError < StandardError; end
end
