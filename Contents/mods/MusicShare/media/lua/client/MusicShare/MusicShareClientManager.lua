MusicShareClientManager = MusicShareClientManager or {}

MusicShareClientManager.MusicShares = {}

function MusicShareClientManager.AddMusicShare(url, title, duration, username, range)
    local now = getTimestamp()
    local musicShare = {
        url = url,
        title = title,
        duration = duration,
        start = now,
        eol = now + duration,
        username = username,
        lastNoteBubble = now,
        range = range
    }
    table.insert(MusicShareClientManager.MusicShares, musicShare)
end

function MusicShareClientManager.RemoveMusicShare(url, username) 
    for i = #MusicShareClientManager.MusicShares, 1, -1 do
        local musicShare = MusicShareClientManager.MusicShares[i]
        if musicShare.url == url and musicShare.username == username then
            table.remove(MusicShareClientManager.MusicShares, i)
        end
    end
end

function MusicShareClientManager.GetMusicSharesInRange()
    local player = getPlayer()
    local musicShares = {}
    for _, musicShare in ipairs(MusicShareClientManager.MusicShares) do
        local emitter = MusicShareClientManager.GetEmitter(musicShare)
        if emitter then
            local dist = player:getDistanceSq(emitter)
            if math.sqrt(dist) <= musicShare.range then
                table.insert(musicShares, musicShare)
            end
        end
    end
    return musicShares
end

function MusicShareClientManager.UpdateMusicShares()
    local now = getTimestamp()
    for i = #MusicShareClientManager.MusicShares, 1, -1 do
        local musicShare = MusicShareClientManager.MusicShares[i]

        if musicShare.lastNoteBubble + 6 < now then
            musicShare.lastNoteBubble = now
            local emitter = MusicShareClientManager.GetEmitter(musicShare)
            if emitter then
                local color = emitter:getSpeakColour()
                emitter:addLineChatElement("[img=music]", color:getR(), color:getG(), color:getB(), UIFont.Dialogue, 0, "default", true, true, true, true, true, true)
            end
        end

        if musicShare.eol < now then
            table.remove(MusicShareClientManager.MusicShares, i)
        end
    end
end

function MusicShareClientManager.GetEmitter(musicShare)
    if musicShare.emitter then
        return musicShare.emitter
    end

    local player = getPlayer()
    if player:getUsername() == musicShare.username then
        musicShare.emitter = player
    else
        musicShare.emitter = getPlayerFromUsername(musicShare.username)
    end

    return musicShare.emitter
end

Events.OnTick.Add(MusicShareClientManager.UpdateMusicShares)