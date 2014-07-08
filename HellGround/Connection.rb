# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require 'eventmachine'
require 'digest/sha1'
require 'openssl'
require 'hexdump'
require 'io/console'

require_relative 'auth'

module HellGround
  IP = '192.168.1.2'
  REALM_PORT = 3724
  WORLD_PORT = 8085
  VERBOSE = ARGV.include? '--verbose'

  module Connection
    def initialize
      @username = ARGV[(ARGV.index '--user') + 1].dup if ARGV.include? '--user'
      @password = ARGV[(ARGV.index '--pass') + 1].dup if ARGV.include? '--pass'

      unless @username
        print 'Enter username: '
        @username = gets.chomp
      end

      unless @password
        print 'Enter password: '
        @password = STDIN.noecho(&:gets).chomp
        puts
      end

      @username.upcase!
      @password.upcase!
    end

    def post_init
      puts "Connecting to server at #{IP}:#{REALM_PORT}..."
      send_data Auth::ClientLogonChallenge.new(@username)
    rescue => e
      puts "Error: #{e.message}"
      EventMachine::stop_event_loop
    end

    def receive_data(data)
      if VERBOSE
        puts "Recv: length #{data.length}"
        data.hexdump
      end

      pk = Packet.new(data)

      case pk.uint8
        when Auth::CMD_AUTH_LOGON_CHALLENGE;  OnServerLogonChallenge(pk)
        when Auth::CMD_AUTH_LOGON_PROOF;      OnServerLogonProof(pk)
        when Auth::CMD_REALM_LIST;            OnServerRealmList(pk)
      end
    rescue AuthError => e
      puts "Authentication error: #{e.message}."
      close
    rescue PacketLengthError => e
      puts "Packet length error: #{e.message}."
      close
    rescue MalformedPacketError => e
      puts "Malformed packet error: #{e.message}."
      close
    rescue => e
      puts "Unexpected error: #{e.message}."
      close
    end

    def send_data(pk)
      if VERBOSE
        puts "Send:"
        pk.dump
      end

      super(pk.data)
    end

    def close
      EventMachine::stop_event_loop
    end

    def unbind
      close
      puts "Connection closed."
    end

    ############################################################################

    def OnServerLogonChallenge(pk)
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
      key = even.split('').zip(odd.split('')).flatten.compact.join.unpack('H*').first.hex

      gnhash = Digest::SHA1.digest(n.hexpack(32)).reverse
      ghash = Digest::SHA1.digest(g.hexpack(1)).reverse
      (0..19).each { |i| gnhash[i] = (gnhash[i].ord ^ ghash[i].ord).chr }
      gnhash = gnhash.unpack('H*').first.hex

      userhash = sha1(@username)
      m1 = sha1(gnhash.hexpack(20) + userhash.hexpack(20) + salt.hexpack(32) +
           a.hexpack(32) + b.hexpack(32) + key.hexpack(40))
      @m2 = sha1(a.hexpack(32) + m1.hexpack(20) + key.hexpack(40))

      send_data Auth::ClientLogonProof.new(a, m1, Auth::CRC_HASH)
    end

    def sha1(str)
      Digest::SHA1.digest(str).reverse.unpack('H*').first.hex
    end

    def rand_bytes(num)
      OpenSSL::Random.random_bytes(32).unpack("H*").first.hex
    end

    def OnServerLogonProof(pk)
      raise ArgumentError, "Packet missing" unless pk

      result = pk.uint8
      raise AuthError, Auth::RESULT_STRING[result] unless result == Auth::RESULT_SUCCESS

      m2 = pk.hex(20)       # M2
      accFlags = pk.uint32  # account flags
      surveyId = pk.uint32  # survey id
      unkFlags = pk.uint16  # unknown flags

      close unless m2 == @m2 # check server key
      @m2 = nil

      send_data Auth::ClientRealmList.new
    end

    def OnServerRealmList(pk)
      raise ArgumentError, "Packet missing" unless pk

      # handle realm list
      close
    end
  end

  class AuthError < StandardError; end

  def self.connect
    EventMachine::run do
      EventMachine::connect IP, REALM_PORT, Connection
    end
  end
end
