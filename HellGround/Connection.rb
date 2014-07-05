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
      begin
        puts "Connecting to server at #{IP}:#{REALM_PORT}..."
        send_data Auth::ClientLogonChallenge.new(@username)
      rescue => e
        puts "Error: #{e.message}"
        EventMachine::stop_event_loop
      end
    end

    def receive_data(data)
      if VERBOSE
        puts "Recv: length #{data.length}"
        data.hexdump
      end

      pk = Packet.new(data)

      begin
        case pk.uint8
          when Auth::CMD_AUTH_LOGON_CHALLENGE;  OnServerLogonChallenge(pk)
          when Auth::CMD_AUTH_LOGON_PROOF;      OnServerLogonProof(pk)
        end
      rescue => e
        puts "Error: #{e.message}."
        close
      end
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

      k = Digest::SHA1.hexdigest("%064x%02x" % [n, g]).hex      # k = H(N|g)
      h = Digest::SHA1.hexdigest("#{@username}:#{@password}")   # h = H(I|:|P)
      x = Digest::SHA1.hexdigest("#{("%064x" % _s) + h}").hex   # x = H(s|h)
      v = g.to_bn.mod_exp(x, n).to_i                            # v = g ** x % N
     _a = OpenSSL::Random.random_bytes(32).unpack("H*").first.hex # a = rand
      a = g.to_bn.mod_exp(_a, n).to_i                           # A = g ** a % N
      u = Digest::SHA1.hexdigest("%064x%064x" % [a, b]).hex     # u = H(A|B)
      s = (b - k * v).to_bn.mod_exp(_a + u * x, n).to_i         # S = (B-k*v)**(a+u*x) % N
      m1 = Digest::SHA1.hexdigest("%064x%064x%064x" % [a, b, s]).hex # M1 = H(A|B|S)

      good_n = 0x894b645e89e1535bbdad5b8b290650530801b18ebfbf5e8fab3c82872a3e9bb7
      raise StandardError, "Got wrong N from server" unless n == good_n
      raise StandardError, "Got wrong g from server" unless g == 0x07

      crc = 0xb0d4782135860ea98764667217e817fbd22cbbd2
      send_data Auth::ClientLogonProof.new(a, m1, crc)
    end

    def OnServerLogonProof(pk)
      raise ArgumentError, "Packet missing" unless pk

      result = pk.uint8
      raise StandardError, Auth::RESULT_STRING[result] unless result == Auth::RESULT_SUCCESS

      m2 = pk.hex(20)
      accFlags = pk.uint32
      surveyId = pk.uint32
      unkFlags = pk.uint16

      puts [m2, m2 == m1, accFlags, surveyId, unkFlags].join(', ')
    end
  end

  def self.connect
    EventMachine::run do
      EventMachine::connect IP, REALM_PORT, Connection
    end
  end
end
