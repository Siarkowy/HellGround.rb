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
      end
    rescue AuthError => e
      puts "Authentication error: #{e.message}."
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

      b = pk.hex(32)  # B
     _g = pk.uint8    # size of g
      g = pk.hex(_g)  # g
     _n = pk.uint8    # size of N
      n = pk.hex(_n)  # N
     _s = pk.hex(32)  # s
      t = pk.hex(16)  # unknown
      f = pk.uint8    # flags

      k = sha1([n.to_s(16) + g.to_s(16)].pack('H*')).hex  # k = H(N|g)
      i = sha1(@username + ':' + @password).hex           # i = H(I|:|P)
      x = sha1([_s.to_s(16) + i.to_s(16)].pack('H*')).hex # x = H(s|i)
      v = g.to_bn.mod_exp(x, n).to_i                      # v = g ** x % N
     _a = rand_bytes(32)                                  # a = rand
      a = g.to_bn.mod_exp(_a, n).to_i                     # A = g ** a % N
      u = sha1([a.to_s(16) + b.to_s(16)].pack('H*')).hex  # u = H(A|B)
      s = (b - k * v).to_bn.mod_exp(_a + u * x, n).to_i   # S = (B-k*v)**(a+u*x) % N
      m1 = sha1([a.to_s(16) + b.to_s(16) + s.to_s(16)].pack('H*')).hex # M1 = H(A|B|S)

      raise MalformedPacketError, "Got wrong N from server" unless n == Auth::N
      raise MalformedPacketError, "Got wrong g from server" unless g == Auth::G

      send_data Auth::ClientLogonProof.new(a, m1, Auth::CRC_HASH)
    end

    def sha1(str)
      Digest::SHA1.hexdigest(str)
    end

    def rand_bytes(num)
      OpenSSL::Random.random_bytes(32).unpack("H*").first.hex
    end

    def OnServerLogonProof(pk)
      raise ArgumentError, "Packet missing" unless pk

      result = pk.uint8
      raise AuthError, Auth::RESULT_STRING[result] unless result == Auth::RESULT_SUCCESS

      m2 = pk.hex(20)
      accFlags = pk.uint32
      surveyId = pk.uint32
      unkFlags = pk.uint16

      puts [m2, m2 == m1, accFlags, surveyId, unkFlags].join(', ')
    end
  end

  class AuthError < StandardError; end

  def self.connect
    EventMachine::run do
      EventMachine::connect IP, REALM_PORT, Connection
    end
  end
end
