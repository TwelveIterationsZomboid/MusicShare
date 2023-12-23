ISMusicShareOverlay = ISPanel:derive("ISMusicShareOverlay");

function ISMusicShareOverlay.createUI()
    if getCore():isDedicated() then 
        return
    end

    ISMusicShareOverlay.destroyUI()

    local x = getPlayerScreenLeft(0)
    local y = getPlayerScreenTop(0)
    local panel = ISMusicShareOverlay:new(x, y, 64, 64)
    panel:initialise()
	panel:addToUIManager()
end

function ISMusicShareOverlay.destroyUI()
    if ISMusicShareOverlay.instance then
        ISMusicShareOverlay.instance:removeFromUIManager();
    end
end

function ISMusicShareOverlay:initialise()
	ISPanel.initialise(self)

    local texWid = self.musicIcon:getWidthOrig()
    local texHgt = self.musicIcon:getHeightOrig()

    self:setX(15)
    self:setWidth(texWid)
    self:setHeight(texHgt)
    
    self.musicBtn = ISButton:new(0, 0, texWid, texHgt, "", self, ISMusicShareOverlay.onClick);
    self.musicBtn:setImage(self.musicIcon);
    self.musicBtn.internal = "MUSICSHARE";
    self.musicBtn:initialise();
    self.musicBtn:instantiate();
    self.musicBtn:setDisplayBackground(false);
    self.musicBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self.musicBtn:ignoreWidthChange();
    self.musicBtn:ignoreHeightChange();
    self:addChild(self.musicBtn);

    local labelHeight = getTextManager():getFontHeight(UIFont.Large) + 3 * 2
    self.songLbl = ISLabel:new(self.musicBtn:getRight() + 4, self.musicBtn:getY() + self.musicBtn:getHeight() / 2, labelHeight, "Nothing", 1, 1, 1, 1, UIFont.Large, true)
    self.songLbl:initialise()
    self.songLbl:setVisible(false)
    self:addChild(self.songLbl)
end

function ISMusicShareOverlay:onClick(button, x, y)
    ISMusicShareDialog.toggleWindow()
end

function ISMusicShareOverlay:prerender()
    self:setY(ISEquippedItem.instance:getBottom() + 4)
	local safetyUI = getPlayerSafetyUI(0)
	if safetyUI ~= nil then
		self:setY(safetyUI:getBottom() + 12)
    elseif ISEquippedItem.instance.adminBtn and ISEquippedItem.instance.adminBtn:getIsVisible() then
        self:setY(ISEquippedItem.instance.adminBtn:getBottom() + 16)
    elseif ISEquippedItem.instance.clientBtn and ISEquippedItem.instance.clientBtn:getIsVisible() then
        self:setY(ISEquippedItem.instance.clientBtn:getBottom() + 16)
    end

    local musicShares = MusicShareClientManager.GetMusicSharesInRange()
    local now = getTimestamp()
    
    -- if just changed, blink the image at an interval, otherwise just show the current state
    if self.nearbySharesChangedAt and now - self.nearbySharesChangedAt < 10 then
        self.musicBtn:setImage(now % 2 == 1 and self.musicIconOn or self.musicIcon)
        self.songLbl:setVisible(true)
    else
        self.musicBtn:setImage(#musicShares > 0 and self.musicIconOn or self.musicIcon)
        self.songLbl:setVisible(#musicShares > 0)
        if #musicShares > 0 then
            local musicShare = musicShares[1]
            self.songLbl:setName(musicShare.title)
        end
    end

    local lastMusicShareCount = self.lastMusicShareCount or 0
    if lastMusicShareCount < #musicShares then
        self.nearbySharesChangedAt = now
    end
    self.lastMusicShareCount = #musicShares

    local labelHeight = getTextManager():getFontHeight(UIFont.Large) * 2
    self.songLbl:setHeight(labelHeight + 6)
    self.songLbl:setX(self.musicBtn:getRight() + 8)
    self.songLbl:setY(self.musicBtn:getY() + self.musicBtn:getHeight() / 2 - labelHeight / 2 - 2)
end

function ISMusicShareOverlay:new(x, y, width, height)
	local o = {}
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self)
    self.__index = self
	o.x = x;
	o.y = y;
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
	o.width = width;
	o.height = height;
    o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
    o.musicIcon = getTexture("media/ui/MusicShare_Icon.png");
    o.musicIconOn = getTexture("media/ui/MusicShare_Icon_On.png");
    ISMusicShareOverlay.instance = o;
	return o;
end

Events.OnCreatePlayer.Add(ISMusicShareOverlay.createUI)
Events.OnPlayerDeath.Add(ISMusicShareOverlay.destroyUI)