# Bot Operations
This gem contains bot operation commands for all my Ruby-based Discord bots. It was designed with my specific ecosystem of bots in mind so if you want to use it, you'll have to edit the code yourself.

## Requirements
This gem assumes that you're using pm2 to manage your bot processes, Bundler to manage your dependencies, and discordrb as your Discord library.

## Setup
1. Run this command in the root of your project:
```bundle add botoperations --github "CaptainM777/ruby-bot-operations"```
2. Add `require 'botoperations'` in the same file as the one you initialize your [CommandBot](https://drb.shardlab.dev/main/Discordrb/Commands/CommandBot.html) object in.

   **Important Note:** Your bot has to have a name passed into the CommandBot constructor in order for  this gem to work correctly. It also has to be exactly the same as the pm2 process name.
3. Assuming that the variable 'bot' is your CommandBot object, add this line to that same file:
```bot.include! BotOperations```

