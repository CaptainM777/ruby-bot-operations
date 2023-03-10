# frozen_string_literal: true

require_relative "botoperations/version"
require "json"
require "open3"

module BotOperations
  extend Discordrb::Commands::CommandContainer
  extend Discordrb::EventContainer

  class Error < StandardError; end

  CAP_ID = 260600155630338048

  def self.bot_name_exists(event)
    if event.bot.name.nil?
      event.send_embed do |embed| 
        embed.description = "❌ Your bot doesn't have a name set! Add it as an argument when " +
                            "[initializing](https://drb.shardlab.dev/main/Discordrb/Bot.html#initialize-instance_method) the bot."
        embed.color = "#e12a2a" 
      end
      return false
    end

    true
  end

  def self.process_exists(event)
    command_output = Open3.capture2("pm2 jlist")[0]
    process_name = JSON.parse(command_output).map{ |process| process["name"] }.find{ |process_name| event.bot.name.downcase == process_name.downcase }

    if process_name.nil?
      event.send_embed do |embed| 
        embed.description = "❌ A managing pm2 process could not be found!"
        embed.color = "#e12a2a"
      end
    end

    process_name
  end

  command :restart, aliases: [:r] do |event|
    break if event.user.id != CAP_ID

    break if !bot_name_exists(event) || !process_exists(event)

    event.send_embed{ |embed| embed.description = "✅ Restarting bot"; embed.color = "#6df67e" }

    `pm2 restart #{event.bot.name.downcase}`
    nil
  end

  command :stop, aliases: [:st] do |event|
    break if event.user.id != CAP_ID

    break if !bot_name_exists(event) || !process_exists(event)
    
    event.send_embed{ |embed| embed.description = "✅ Stopping bot"; embed.color = "#6df67e" }

    `pm2 stop #{event.bot.name.downcase}`
    nil
  end

  command :logs, min_args: 1 do |event, log_type, lines|
    break if event.user.id != CAP_ID

    if !["out", "err"].include?(log_type)
      event.send_embed{ |embed| embed.description = "❌ You have to specify either an 'out' or 'err' log type!"; embed.color = "#e12a2a" }
      break
    end

    lines = lines || 50

    if lines.to_i < 10
      event.send_embed{ |embed| embed.description = "❌ You have to provide at least 10 lines minimum!"; embed.color = "#e12a2a" }
      break
    end
    
    break if !bot_name_exists(event) || !(process_name = process_exists(event))

    command_output = Open3.capture3("pm2 logs #{process_name} --raw --nostream --lines #{lines}")
    log_file_contents = log_type == "out" ? command_output[0] : command_output[1]

    begin
      event.send_embed do |embed|
        embed.color = 0xFFD700
        embed.description = "```#{log_file_contents}```"
      end
    rescue Discordrb::Errors::InvalidFormBody
      event.send_embed{ |embed| embed.description = "❌ Embed is too large! Try providing a smaller number of lines."; embed.color = "#e12a2a" }
    end
  end
end
