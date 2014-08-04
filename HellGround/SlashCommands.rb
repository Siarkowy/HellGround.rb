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

  def OnSlashFriend(cmd, args)
    @social.friend args unless args.empty?
  end

  def OnSlashFriends(cmd, args)
    puts 'Friends:'
    @social.friends.each { |guid, social| puts social.to_char }
  end

  def OnSlashGuild(cmd, args)
    return if args.empty?

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

  def OnSlashIgnore(cmd, args)
    @social.ignore args unless args.empty?
  end

  def OnSlashIgnores(cmd, args)
    puts 'Ignores:'
    @social.ignores.each { |guid, social| puts social.to_char }
  end

  def OnSlashItem(cmd, args)
    return if args.empty?

    if item = World::Item.find(args.to_i)
      puts item
    else
      send_data World::Packets::ClientItemQuery.new(args.to_i)
    end
  end

  def OnSlashJoin(cmd, args)
    @chat.join args unless args.empty?
  end

  def OnSlashLeave(cmd, args)
    @chat.leave args unless args.empty?
  end

  def OnSlashLogin(cmd, args)
    return if @chars.nil? || args.empty?

    if player = @chars.select { |player| player.to_char.name == args }.first
      @player = player

      puts "Logging in as #{player.to_char.name}."
      send_data World::Packets::ClientPlayerLogin.new(player)
    else
      puts "Character not found."
    end
  end

  def OnSlashLogout(cmd, args)
    send_data World::Packets::ClientLogoutRequest.new
  end

  def OnSlashOfficer(cmd, args)
    return if args.empty?

    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_OFFICER,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashParty(cmd, args)
    return if args.empty?

    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_PARTY,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashQuest(cmd, args)
    return if args.empty?

    if quest = World::Quest.find(args.to_i)
      puts quest
    else
      send_data World::Packets::ClientQuestQuery.new(args.to_i)
    end
  end

  def OnSlashQuit(cmd, args)
    stop!
  end

  def OnSlashReply(cmd, args)
    return if @whisper_target.nil? || args.empty?

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
    return if args.empty?

    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_SAY,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashUnfriend(cmd, args)
    @social.unfriend args unless args.empty?
  end

  def OnSlashUnignore(cmd, args)
    @social.unignore args unless args.empty?
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
    return if args.empty?

    @chat.send World::ChatMessage.new(
      World::ChatMessage::CHAT_MSG_YELL,
      @player.lang,
      @player.guid,
      args
    )
  end

  def OnSlashWhois(cmd, args)
    send_data World::Packets::ClientNameQuery.new(args.to_i) unless args.empty?
  end

  SLASH_HANDLERS = {
    :help       => :OnSlashHelp,        # lists available commands
    :"?"        => :OnSlashHelp,

    :channel    => :OnSlashChannel,     # sends channel message
    :c          => :OnSlashChannel,
    :guild      => :OnSlashGuild,       # sends guild message
    :friend     => :OnSlashFriend,      # adds a friend
    :friends    => :OnSlashFriends,     # lists friends
    :g          => :OnSlashGuild,
    :ignore     => :OnSlashIgnore,      # ignores a player
    :ignores    => :OnSlashIgnores,     # lists ignores
    :item       => :OnSlashItem,        # item lookup
    :join       => :OnSlashJoin,        # joins a channel
    :leave      => :OnSlashLeave,       # leaves a channel
    :login      => :OnSlashLogin,       # character selection
    :logout     => :OnSlashLogout,      # logout request
    :officer    => :OnSlashOfficer,     # sends officer message
    :o          => :OnSlashOfficer,
    :party      => :OnSlashParty,       # sends party message
    :p          => :OnSlashParty,
    :reply      => :OnSlashReply,       # replies last whisper target
    :r          => :OnSlashReply,
    :quest      => :OnSlashQuest,       # quest lookup
    :quit       => :OnSlashQuit,        # quits
    :roster     => :OnSlashRoster,      # guild roster query
    :say        => :OnSlashSay,         # says
    :s          => :OnSlashSay,
    :yell       => :OnSlashYell,        # yells
    :y          => :OnSlashYell,
    :unfriend   => :OnSlashUnfriend,    # deletes a friend
    :unignore   => :OnSlashUnignore,    # deletes an ignore
    :whisper    => :OnSlashWhisper,     # whispers
    :w          => :OnSlashWhisper,
    :whois      => :OnSlashWhois,       # who query
  }
end
