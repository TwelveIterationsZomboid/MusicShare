MusicShareServerCommands = MusicShareServerCommands or {}

function MusicShareServerCommands.OnServerCommand(module, command, args)
	if module == 'musicShare' and MusicShareServerCommands[command] then
		local argStr = ''
		args = args or {}
		for k,v in pairs(args) do
			argStr = argStr..' '..k..'='..tostring(v)
		end
		--print('received '..module..' '..command..' '..tostring(player)..argStr)
		MusicShareServerCommands[command](args)
	end
end

function MusicShareServerCommands.StartMusic(args)
	local url = args.url
	local range = args.range
	local title = args.title
	local duration = args.duration
	local username = args.username
	MusicShareClientManager.AddMusicShare(url, title, duration, username, range)
end

function MusicShareServerCommands.StopMusic(args)
	local url = args.url
	local username = args.username
	MusicShareClientManager.RemoveMusicShare(url, username)
end

Events.OnServerCommand.Add(MusicShareServerCommands.OnServerCommand)