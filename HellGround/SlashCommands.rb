# HellGround.rb, HellGround Core chat client written in Ruby
# Copyright (C) 2014 Siarkowy <siarkowy@siarkowy.net>
# See LICENSE file for more information on licensing.

# Slash command handlers.
module HellGround::SlashCommands
  World = HellGround::World

  # Parses user input for slash commands.
  # @param line [String] User input.
  def OnReceiveLine(line)
    line.chomp.match(/^\/([a-zA-Z?]+)\s*(.*)/) do |m|
      cmd   = m[1]
      args  = m[2]

      handler = SLASH_HANDLERS[cmd.to_sym]
      method(handler).call(cmd, args) if handler
      puts "There is no such command." unless handler
    end
  end

  def OnSlashChannel(cmd, args)
    args.match(/(\S+)\s*(.+)/) do |m|
      @chat.send World::ChatMessage.new(
        World::ChatMessage::CHAT_MSG_CHANNEL,
        @player.lang,
        @player.guid,
        m[2],
        m[1]
      )
    end
  end

  def OnSlashGuild(cmd, args)
    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_GUILD,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashHelp(cmd, args)
    puts "Available commands are:"
    SLASH_HANDLERS.each { |cmd, meth| print format '%-10s', "/#{cmd}" }
    puts
  end

  def OnSlashItem(cmd, args)
    World::Item.find(args.to_i) { |i| puts i; return }
    send_data World::Packets::ClientItemQuery.new(args.to_i)
  end

  def OnSlashJoin(cmd, args)
    @chat.join args
  end

  def OnSlashLeave(cmd, args)
    @chat.leave args
  end

  def OnSlashLogin(cmd, args)
    return unless @chars

    char = @chars.select { |char| char.name == args }.first

    if char
      @player = char

      puts "Logging in as #{char.name}."
      send_data World::Packets::ClientPlayerLogin.new(char)
    else
      puts "Character not found."
    end
  end

  def OnSlashLogout(cmd, args)
    send_data World::Packets::ClientLogoutRequest.new
  end

  def OnSlashOfficer(cmd, args)
    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_OFFICER,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashParty(cmd, args)
    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_PARTY,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashQuest(cmd, args)
    World::Quest.find(args.to_i) { |q| puts q; return }
    send_data World::Packets::ClientQuestQuery.new(args.to_i)
  end

  def OnSlashQuit(cmd, args)
    stop!
  end

  def OnSlashReply(cmd, args)
    return unless @whisper_target

    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_WHISPER,
      @player.lang,
      @player.guid,
      args,
      @whisper_target
    )
  end

  def OnSlashRoster(cmd, args)
    send_data World::Packets::ClientGuildRoster.new
  end

  def OnSlashSay(cmd, args)
    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_SAY,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashWhisper(cmd, args)
    args.match(/(\S+)\s*(.+)/) do |m|
      @whisper_target = m[1]

      @chat.send World::ChatMessage.new(
        World::ChatMessage::CHAT_MSG_WHISPER,
        @player.lang,
        @player.guid,
        m[2],
        m[1]
      )
    end
  end

  def OnSlashYell(cmd, args)
    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_YELL,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashWhois(cmd, args)
    send_data World::Packets::ClientNameQuery.new(args.to_i)
  end

  SLASH_HANDLERS = {
    :help     => :OnSlashHelp,    # lists available commands
    :"?"      => :OnSlashHelp,

    :channel  => :OnSlashChannel, # sends channel message
    :c        => :OnSlashChannel,
    :guild    => :OnSlashGuild,   # sends guild message
    :g        => :OnSlashGuild,
    :item     => :OnSlashItem,    # item lookup
    :join     => :OnSlashJoin,    # joins a channel
    :leave    => :OnSlashLeave,   # leaves a channel
    :login    => :OnSlashLogin,   # character selection
    :logout   => :OnSlashLogout,  # logout request
    :officer  => :OnSlashOfficer, # sends officer message
    :o        => :OnSlashOfficer,
    :party    => :OnSlashParty,   # sends party message
    :p        => :OnSlashParty,
    :reply    => :OnSlashReply,   # replies last whisper target
    :r        => :OnSlashReply,
    :quest    => :OnSlashQuest,   # quest lookup
    :quit     => :OnSlashQuit,    # quits
    :roster   => :OnSlashRoster,  # guild roster query
    :say      => :OnSlashSay,     # says
    :s        => :OnSlashSay,
    :yell     => :OnSlashYell,    # yells
    :y        => :OnSlashYell,
    :whisper  => :OnSlashWhisper, # whispers
    :w        => :OnSlashWhisper,
    :whois    => :OnSlashWhois,   # who query
  }
end
