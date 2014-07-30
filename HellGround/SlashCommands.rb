# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

module HellGround::SlashCommands
  def OnReceiveLine(line)
    line.chomp.match(/^\/(\w+)\s*(.*)/) do |m|
      cmd   = m[1]
      args  = m[2]

      handler = SLASH_HANDLERS[cmd.to_sym]
      method(handler).call(cmd, args) if handler
      puts "There is no such command." unless handler
    end
  end

  def OnSlashSelect(cmd, args)
    return unless @chars

    char = @chars.select { |char| char.name == args }.first

    if char
      @player = char
      @chars = nil

      puts "Logging in as #{char.name}."
      send_data HellGround::World::ClientPlayerLogin.new(char)
    else
      puts "Character not found."
    end
  end

  def OnSlashQuit(cmd, args)
    stop!
  end

  SLASH_HANDLERS = {
    :login    => :OnSlashSelect,
    :select   => :OnSlashSelect,
    :quit     => :OnSlashQuit
  }
end
