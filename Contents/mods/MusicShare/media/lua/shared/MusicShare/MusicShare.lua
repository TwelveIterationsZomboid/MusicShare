MusicShare = MusicShare or {}

function MusicShare.ExtractYouTubeId(url)
    local id = url:match("v=([a-zA-Z0-9-_]+)")
    if id then return id end
    id = url:match("youtu.be/([a-zA-Z0-9-_]+)")
    if id then return id end
    id = url:match("youtube.com/embed/([a-zA-Z0-9-_]+)")
    if id then return id end
    id = url:match("youtube.com/v/([a-zA-Z0-9-_]+)")
    if id then return id end
    id = url:match("youtube.com/watch/([a-zA-Z0-9-_]+)")
    if id then return id end
    return nil
end

function MusicShare.FetchYouTubeMetadata(url)
    local id = MusicShare.ExtractYouTubeId(url)
    if not id then return nil end
    local url = "https://music-share-server.twelveiterations.workers.dev/?v=" .. id -- TODO make this configurable
    local stream = getUrlInputStream(url)
    if not stream then return nil end
    local url = stream:readLine()
    local title = stream:readLine()
    local duration = stream:readLine()
    return {url = url, title = title, duration = duration}
end