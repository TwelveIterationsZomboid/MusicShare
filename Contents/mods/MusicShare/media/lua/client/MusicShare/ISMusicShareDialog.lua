require "ISUI/ISCollapsableWindow";

ISMusicShareDialog = ISCollapsableWindow:derive("ISMusicShareDialog");

function ISMusicShareDialog:update()
	if (not self:getIsVisible()) then 
        return
    end
	
    local musicShares = MusicShareClientManager.GetMusicSharesInRange()
    if #musicShares ~= self.lastMusicShareCount then
        self:updateList(musicShares)
    end
    self.lastMusicShareCount = #musicShares
end

function ISMusicShareDialog:updateList(musicShares)
    for _, entry in ipairs(self.entries) do
        self:removeChild(entry.label)
        self:removeChild(entry.button)
    end

    if #musicShares == 0 then
        self.noMusicLbl:setVisible(true)
        self.playMusicBtn:setVisible(true)
        self.stopMusicBtn:setVisible(false)
        self.effectiveBottom = self.noMusicLbl:getBottom()
        self.effectiveWidth = math.max(240, self.noMusicLbl:getWidth())
    else
        self.noMusicLbl:setVisible(false)
        self.effectiveWidth = 240

        local player = getPlayer()
        local y = 20
        for _, musicShare in ipairs(musicShares) do
            local label = ISLabel:new(30, y, 20, musicShare.title, 0.7, 0.7, 0.7, 1, UIFont.Small, true)
            label:initialise();
            label:setWidthToName(240)
            self:addChild(label)

            local button = ISButton:new(300 - 90, y, 60, 20, getText("UI_MusicShare_listen"), self, ISMusicShareDialog.ListenMusic)
            button.musicShare = musicShare
            button:initialise();
            self:addChild(button)

            y = y + 20
            self.effectiveBottom = label:getBottom()
            self.effectiveWidth = math.max(self.effectiveWidth, label:getWidth() + 30)
            table.insert(self.entries, {label = label, button = button})

            if musicShare.username == player:getUsername() then
                self.playMusicBtn:setVisible(false)
                self.stopMusicBtn:setVisible(true)
                self.stopMusicBtn.musicShare = musicShare
            end
        end
    end

    self.playMusicBtn:setY(self.effectiveBottom + 10)
    self.stopMusicBtn:setY(self.effectiveBottom + 10)
    self:setHeight(self.playMusicBtn:getBottom() + 12)
    self:setWidth(self.effectiveWidth + 60)
    self.playMusicBtn:setWidth(self.effectiveWidth)
    self.stopMusicBtn:setWidth(self.effectiveWidth)

    for _, entry in ipairs(self.entries) do
        entry.button:setX(self.effectiveWidth + 30 - entry.button:getWidth())
    end
end

function ISMusicShareDialog:initialise()
	ISCollapsableWindow.initialise(self)
	
    local labelText = getText("UI_MusicShare_noMusic")
	local labelHeight = getTextManager():getFontHeight(UIFont.Small) + 3 * 2
	local labelWidth = getTextManager():MeasureStringX(UIFont.Small, labelText)
    self.noMusicLbl = ISLabel:new(self:getWidth() / 2 - labelWidth / 2, 20, labelHeight, labelText, 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self.noMusicLbl:initialise();
    self:addChild(self.noMusicLbl)

    self.effectiveBottom = self.noMusicLbl:getBottom()

	self.playMusicBtn = ISButton:new(30, self.effectiveBottom + 10, 300 - 60, 20, getText("UI_MusicShare_playMusic"), self, ISMusicShareDialog.PlayMusic)
	self:addChild(self.playMusicBtn)

    self.stopMusicBtn = ISButton:new(30, self.effectiveBottom + 10, 300 - 60, 20, getText("UI_MusicShare_stopMusic"), self, ISMusicShareDialog.StopMusic)
    self.stopMusicBtn:setVisible(false)
	self:addChild(self.stopMusicBtn)

	self:addToUIManager()
	self:update()
	self:bringToTop()
    self:setHeight(self.playMusicBtn:getBottom() + 12)

	ISLayoutManager.RegisterWindow('ISMusicShareDialog', ISMusicShareDialog, self)
end

function ISMusicShareDialog.PlayMusic()
    local width = 280
    local height = 120
    local modal = ISTextBox:new(0, 0, width, height, getText("IGUI_MusicShare_EnterYouTubeURL"), "", nil, ISMusicShareDialog.PlayMusicSubmit)
    modal:setValidateFunction(nil, ISMusicShareDialog.LinkValidate)
    modal:setValidateTooltipText(getText("IGUI_MusicShare_EnterYouTubeURL_Invalid"))
    
    modal.x = (getCore():getScreenWidth() / 2) - (width / 2)
    modal:setX(modal.x)
    modal.y = (getCore():getScreenHeight() / 2) - (height / 2)
    modal:setY(modal.y)
    modal:initialise()
    modal:addToUIManager()
end

function ISMusicShareDialog.ListenMusic(target, button)
    local timePassed = getTimestamp() - button.musicShare.start
    if timePassed < 10 then
        openUrl(button.musicShare.url)
    else
        openUrl(button.musicShare.url .. "&t=" .. tostring(timePassed))
    end
end

function ISMusicShareDialog.StopMusic(target, button)
    local player = getPlayer()
    sendClientCommand(getPlayer(), "musicShare", "StopMusic", {url = button.musicShare.url})
end

function ISMusicShareDialog.PlayMusicSubmit(target, button)
    local text = button.parent.entry:getText()
    if text and text ~= "" then
        sendClientCommand(getPlayer(), "musicShare", "StartMusic", {url = text, range = 25})
    end
end

function ISMusicShareDialog.LinkValidate(target, text)
    return text ~= nil and (text:sub(1, 7) == "http://" or text:sub(1, 8) == "https://") and (text:find("youtube.com/watch") or text:find("youtu.be/"))
end

function ISMusicShareDialog:new()
	local o = ISCollapsableWindow:new(0, 0, 300, 0);
	setmetatable(o, self);
	self.__index = self;
	o.x                 	= 120;
	o.y                 	= 300;
	o.width             	= 300;
	o.height            	= 170;
	o.showBackground    	= true;
	o.showBorder        	= true;
	o.backgroundColor   	= {r=0, g=0, b=0, a=1};
	o.borderColor       	= {r=0.4, g=0.4, b=0.4, a=0};
	o.title             	= getText("UI_MusicShare_title")
    o.entries = {}
	o:setResizable(false);
	o:setDrawFrame(true);
	o:initialise();
    ISMusicShareDialog.instance = o;
	return o;
end

function ISMusicShareDialog.toggleWindow()
    if not ISMusicShareDialog.instance then
        ISMusicShareDialog.createUI()
    end
    local dialog = ISMusicShareDialog.instance
	if dialog then
		dialog:setVisible(not dialog:getIsVisible())
		dialog:bringToTop()
	end
end

function ISMusicShareDialog.showWindow()
    if not ISMusicShareDialog.instance then
        ISMusicShareDialog.createUI()
    end
	if ISMusicShareDialog.instance then
		ISMusicShareDialog.instance:setVisible(true)
		ISMusicShareDialog.instance:bringToTop()
	end
end

function ISMusicShareDialog.createUI()
    ISMusicShareDialog.destroyUI()
    local dialog = ISMusicShareDialog:new()
    dialog:setVisible(false)
end

function ISMusicShareDialog.destroyUI()
    if ISMusicShareDialog.instance then
        ISMusicShareDialog.instance:removeFromUIManager();
    end
end

Events.OnCreatePlayer.Add(ISMusicShareDialog.createUI)
Events.OnPlayerDeath.Add(ISMusicShareDialog.destroyUI)