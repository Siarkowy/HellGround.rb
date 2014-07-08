# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require 'eventmachine'
require 'hexdump'
require 'io/console'

require_relative 'auth'
require_relative 'handlers'

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
      puts "Connecting to realm server at #{IP}:#{REALM_PORT}."
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
      handler = SMSG_HANDLERS[pk.uint8]
      self.method(handler).call(pk) if handler
    rescue AuthError => e
      puts "Authentication error: #{e.message}."
      close
    rescue UnsupportedPacketError => e
      puts "Unsupported packet warning: #{e.message}."
      # close
    rescue => e
      puts "#{e.message}."
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

    SMSG_HANDLERS = {
      Auth::CMD_AUTH_LOGON_CHALLENGE  => :OnLogonChallenge,
      Auth::CMD_AUTH_LOGON_PROOF      => :OnLogonProof,
      Auth::CMD_REALM_LIST            => :OnRealmList,
    }

    SMSG_HANDLERS.default = :OnOtherPacket
  end

  def self.connect
    EventMachine::run do
      EventMachine::connect IP, REALM_PORT, Connection
    end
  end
end
