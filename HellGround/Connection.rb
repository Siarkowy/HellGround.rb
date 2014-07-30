# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

require 'eventmachine'
require 'hexdump'
require 'io/console'

require_relative 'Utils'
require_relative 'Auth'
require_relative 'SlashCommands'
require_relative 'World'

module HellGround
  VERBOSE = ARGV.include?('--verbose') || ARGV.include?('-v')

  CHAR =
    if ARGV.include? '--char'
      ARGV[(ARGV.index '--char') + 1].dup
    else
      nil
    end

  class KeyboardHandler < EM::Connection
    include EM::Protocols::LineText2

    def receive_line(data)
      $conn.OnReceiveLine(data)
    end
  end

  def self.connect! # FIXME: Use OptionParser for parameters.
    user = ARGV[(ARGV.index '--user') + 1].dup if ARGV.include? '--user'
    pass = ARGV[(ARGV.index '--pass') + 1].dup if ARGV.include? '--pass'

    unless user
      print 'Enter user: '
      user = gets.chomp
    end

    unless pass
      print 'Enter pass: '
      pass = STDIN.noecho(&:gets).chomp
      puts
    end

    EM::run do
      $conn = EM::connect(Auth::REALM_IP, Auth::REALM_PORT, Auth::Connection, user, pass)
      EM::open_keyboard(KeyboardHandler)
    end
  end
end
