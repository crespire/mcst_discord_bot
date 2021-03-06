require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('config.yaml')
PERMISSIONS = YAML.load_file('permissions.yaml')
bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], client_id: 951501962585726977, prefix: '>'

puts "Bot invite link: #{bot.invite_url}"
puts "Bot active channels: #{PERMISSIONS['channels']}"
puts "Role IDs allowed for request: #{PERMISSIONS['request']}"
puts "Role IDs allowed for manage: #{PERMISSIONS['manage']}"

bot.command(:close, allowed_roles: PERMISSIONS['manage'], channels: PERMISSIONS['channels'], description: 'Command to test permission setting.') do |event|
  event.respond 'Close ticket command'
end

bot.command(:meta, help_available: false) do |event|
  event.respond 'You found the hidden command!'
end

bot.command(:request, min_args: 2, allowed_roles: PERMISSIONS['request'], channels: PERMISSIONS['channels'], description: 'Takes a request and creates a ticket to be resolved. Request multiple items by separating `[number][name]` with a comma.', usage: 'request [number][item name/description](, [number][name of additional items])') do |event, *args|
  pairs = transform_input(args)
  event << "Transformed data: #{pairs}"

  request_hash = {}
  pairs.each do |pair|
    quantity, *item = pair.split(' ')
    request_hash[item.join(' ')] = quantity
  end

  event << "Hash: #{request_hash}"
  event << "Your ticket has been received, #{event.user.mention}"
end

def transform_input(args)
  input = args.join(' ')
  input.gsub!(/(\ba\b|\ban\b)/, '1')
  input.gsub!(/(\bone\b)/, '1')
  pairs = []
  input.split(',').chunk { |el| el.match(/[[:digit:]]/) }.each { |_, chunk| pairs << chunk.pop.strip }
  pairs
end

bot.run


=begin
Considerations

* All raiders should be able to request
* Raiders requests should be tied to their username
* Raiders be able to edit or cancel their own requests
* Managers should be able to edit or cancel all requests.

I think, to start, we should purely interact with the Rails API via discord.
This might be a little easier to manage for now, but we can always update the app later to allow messages to be sent from the web app.

Idea is: discord bot works as the front end and the Rails API backend handles all the actual data persistence.

In the future, it might be cool for managers to be able to log onto a web view, and handle tickets there, and have the bot automatically notify folks on discord.
=end