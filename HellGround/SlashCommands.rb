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

  def OnSlashItem(cmd, args)
    HellGround::World::Item.find(args.to_i) { |i| puts i; return }
    send_data HellGround::World::ClientItemQuery.new(args.to_i)
  end

  def OnSlashLogin(cmd, args)
    return unless @chars

    char = @chars.select { |char| char.name == args }.first

    if char
      @player = char

      puts "Logging in as #{char.name}."
      send_data HellGround::World::ClientPlayerLogin.new(char)
    else
      puts "Character not found."
    end
  end

  def OnSlashLogout(cmd, args)
    send_data HellGround::World::ClientLogoutRequest.new
  end

  def OnSlashQuest(cmd, args)
    HellGround::World::Quest.find(args.to_i) { |q| puts q; return }
    send_data HellGround::World::ClientQuestQuery.new(args.to_i)
  end

  def OnSlashQuit(cmd, args)
    stop!
  end

  def OnSlashWhois(cmd, args)
    send_data HellGround::World::ClientNameQuery.new(args.to_i)
  end

  SLASH_HANDLERS = {
    :item     => :OnSlashItem,
    :login    => :OnSlashLogin,
    :logout   => :OnSlashLogout,
    :quest    => :OnSlashQuest,
    :quit     => :OnSlashQuit,
    :whois    => :OnSlashWhois,
  }
end
