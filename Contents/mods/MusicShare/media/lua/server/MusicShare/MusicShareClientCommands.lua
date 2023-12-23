MusicShareClientCommands = MusicShareClientCommands or {}

function MusicShareClientCommands.OnClientCommand(module, command, player, args)
	if module == 'musicShare' and MusicShareClientCommands[command] then
		local argStr = ''
		args = args or {}
		for k,v in pairs(args) do
			argStr = argStr..' '..k..'='..tostring(v)
		end
		--print('received '..module..' '..command..' '..tostring(player)..argStr)
		MusicShareClientCommands[command](player, args)
	end
end

function MusicShareClientCommands.StartMusic(player, args)
    local url = args.url
    local range = args.range
    local metadata = MusicShare.FetchYouTubeMetadata(url) or {
        url = url,
        title = "Unknown",
        duration = 180
    }
    if getCore():isDedicated() then
        sendServerCommand("musicShare", "StartMusic", {url = metadata.url, title = metadata.title, duration = metadata.duration, username = player:getUsername(), range = range})
    else
        MusicShareClientManager.AddMusicShare(metadata.url, metadata.title, metadata.duration, player:getUsername(), range)
    end
end

function MusicShareClientCommands.StopMusic(player, args)
    if getCore():isDedicated() then
        sendServerCommand("musicShare", "StopMusic", {url = args.url, username = player:getUsername()})
    else
        MusicShareClientManager.RemoveMusicShare(args.url, player:getUsername())
    end
end


Events.OnClientCommand.Add(MusicShareClientCommands.OnClientCommand)