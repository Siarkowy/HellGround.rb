# HellGround.rb, WoW protocol implementation in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require_relative 'packet'

require 'digest/sha1'
require 'openssl'

require_relative 'Auth/Handlers'
require_relative 'Auth/Packets'

module HellGround::Auth
  class Connection < EM::Connection
    include Handlers
    include HellGround::Utils

    attr_writer :callbacks

    def initialize(app, username, password)
      extend HellGround::Callbacks

      @app      = app
      @username = username.upcase
      @password = password.upcase

      yield self if block_given?
    end

    def post_init
      send_data ClientLogonChallenge.new(@username)
    end

    def receive_data(data)
      pk = Packet.new(data)
      notify :packet_received, pk

      handler = SMSG_HANDLERS[pk.uint8]
      method(handler).call(pk) if handler
    rescue AuthError => e
      notify :auth_error, e
      stop!
    end

    def send_data(pk)
      notify :packet_sent, pk
      super(pk.data)
    end

    def stop!
      EM::stop_event_loop
    end

    def OnReceiveLine(line) end
  end

  class AuthError < StandardError; end
end
