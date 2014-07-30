# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require_relative 'packet'

require 'digest/sha1'
require 'openssl'

require_relative 'Auth/Handlers'
require_relative 'Auth/Packets'

module HellGround::Auth
  REALM_IP = '192.168.1.2'
  REALM_PORT = 3724

  class Connection < EM::Connection
    include Handlers
    include HellGround::Utils

    def initialize(username, password)
      @username = username.upcase
      @password = password.upcase
    end

    def post_init
      puts "Connecting to realm server at #{REALM_IP}:#{REALM_PORT}."
      send_data ClientLogonChallenge.new(@username)
    rescue => e
      puts "Error: #{e.message}"
      stop!
    end

    def receive_data(data)
      pk = Packet.new(data)
      puts pk if HellGround::VERBOSE

      handler = SMSG_HANDLERS[pk.uint8]
      method(handler).call(pk) if handler
    rescue AuthError => e
      puts "Authentication error: #{e.message}."
      stop!
    rescue => e
      puts e.message
      stop!
    end

    def send_data(pk)
      puts pk if HellGround::VERBOSE
      super(pk.data)
    end

    def stop!
      EM::stop_event_loop
    end

    def OnReceiveLine(line) end
  end

  class AuthError < StandardError; end
end
