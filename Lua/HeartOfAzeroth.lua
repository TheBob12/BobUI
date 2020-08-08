function showHeartEssences()
	
	if C_AzeriteItem.FindActiveAzeriteItem() == nil then 
		return false
	else
		if C_AzeriteItem.GetPowerLevel(C_AzeriteItem.FindActiveAzeriteItem()) < 50 then 
			return false
		end
		if not C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped() then
			return false
		end
	end

	return true
end

function displayHeartEssenceSlots()
    local EssenceFrame = BobUI_PlayerTalentFrameTalentsEssences

    --local spellButtonSizeWithBorders = BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2) -- should be a global. 
    --local EssenceFrameWidth = max(spellButtonSizeWithBorders + 30, EssenceFrame.titleFrame.category:GetWidth() + 10)
    --local EssenceFrameHeight = ((spellButtonSizeWithBorders + 10) * 4) + EssenceFrame.titleFrame.category:GetHeight() - 10
    --local EssenceListFrameHeight = 0
    --local EssenceListFrameWidth = 0

    if EssenceFrame.essenceList.buttons ~= nil then
        local numShownButtons = 0

        for k, v in pairs(EssenceFrame.essenceList.buttons) do
            if v.unlocked == true then
                numShownButtons = numShownButtons + 1
            end
        end

        --EssenceListFrameHeight = ((spellButtonSizeWithBorders + 2) * ceil(numShownButtons / 3)) - 2
        --EssenceListFrameWidth = ((spellButtonSizeWithBorders + 2) * 3) - 2
    end


    if showHeartEssences() then
        if EssenceFrame.essenceList:IsShown() then
            --EssenceFrameWidth = min(spellButtonSizeWithBorders + 30, EssenceFrame.titleFrame.category:GetWidth() + 10) + EssenceListFrameWidth
        end

        BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.borderRight:Show() -- border should be moved out of PVP talent frame and into essence frame.
        EssenceFrame:Show()
        
        --EssenceFrame:SetWidth(max(EssenceFrameWidth,EssenceFrame.titleFrame.category:GetWidth() + 10))
        --EssenceFrame.essenceList:SetWidth(EssenceListFrameWidth)
    
        --EssenceFrame:SetHeight(EssenceFrame.essenceList:IsShown() and (EssenceListFrameHeight + EssenceFrame.titleFrame.category:GetHeight()) or EssenceFrameHeight)
        --EssenceFrame.essenceList:SetHeight(EssenceListFrameHeight)
	else
		BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.borderRight:Hide()
        EssenceFrame:Hide()
    end

    if BobUI_AbilityTab:IsShown() then
        BobUI_AbilityTab:Hide()
        BobUI_AbilityTab:Show()
    end

    --BobUI_updateSize()
end



function GetEssenceList(self)
	if showHeartEssences() then
		self:Show()
		if self.buttons == nil then
			self.buttons = {}
		end

		local essenceList = C_AzeriteEssence.GetEssences()
		local firstOfLastLine = nil 
		local previousButton = nil
		local j = 1

		for i=1, max(#essenceList, #self.buttons) do
			local button

			if self.buttons[i] == nil then
				button = CreateFrame("Button", "HeartEssenceButton"..i, self, "BobUI_HeartEssenceButtonTemplate");
				table.insert(self.buttons, button)
			else
				button = self.buttons[i]
			end

			button:Hide()

			if i > #essenceList then
				--
			else 
				if essenceList[i].valid == true then
					button:SetSize(BobUI_Settings["SpellIconSize"], BobUI_Settings["SpellIconSize"])

					if j == 1 then
						button:SetPoint("TOPLEFT", self, "TOPLEFT")
						firstOfLastLine = button
						previousButton = button
					else 
						if (math.fmod(j-1,3) == 0) then
							button:SetPoint("TOPLEFT", firstOfLastLine, "BOTTOMLEFT", 0, -2)
							firstOfLastLine = button
							previousButton = button
						else
							button:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", 2, 0)
							
							previousButton = button
						end
					end

					button.Texture:SetTexture(essenceList[i].icon)
					button.essenceID = essenceList[i].ID
					button.rank = essenceList[i].rank
					button.essenceName = essenceList[i].name
					button.unlocked = essenceList[i].unlocked

					if essenceList[i].unlocked then
						button.Texture:SetDesaturated(false)
					else
						button.Texture:SetDesaturated(true)
					end

					button:Show()
					j = j + 1
				else
					button:Hide()
				end
			end
		end
	else
		self:Hide()
	end
end

function setupHeartEssences(self)
	if showHeartEssences() then
		if self == nil then self = BobUI_PlayerTalentFrameTalentsEssences end
		
		local j = 1;
		local slot = {};
		local SlottedEssences = {}
		local Milestones = C_AzeriteEssence.GetMilestones();

		for i=1,#Milestones do 
			if Milestones[i].slot ~= nil and Milestones[i].unlocked == true then 
				slot[j] = Milestones[i].ID; 

				if C_AzeriteEssence.GetMilestoneEssence(Milestones[i].ID) then
					SlottedEssences[j] = C_AzeriteEssence.GetEssenceInfo(C_AzeriteEssence.GetMilestoneEssence(Milestones[i].ID))
				end 

				j = j + 1; 
			end 
		end

		for i=1, #self.Slots do 
			if SlottedEssences[i] ~= nil then
				self.Slots[i].Texture:SetTexture(SlottedEssences[i].icon)
				self.Slots[i].essenceID = SlottedEssences[i].ID
				self.Slots[i].rank = SlottedEssences[i].rank
			else
				self.Slots[i].essenceID = nil
				self.Slots[i].rank = nil
				self.Slots[i].Texture:SetTexture(nil)
				self.Slots[i].Texture:SetAtlas("pvptalents-talentborder-empty");
			end
			
			self.Slots[i].slot = i
			self.Slots[i].milestoneID = slot[i]
			self.Slots[i]:OnShow()
		end
	else
		self:Hide()
	end
end


BobUI_HeartEssenceSlotMixin = {}
SELECTED_HEART_ESSENCE_SLOT = nil

function BobUI_HeartEssenceSlotMixin:OnShow()
	if BobUI_Globals["LOADED"] == false then return end
	
	if self.rank ~= nil then
		local color = ITEM_QUALITY_COLORS[self.rank + 1];
		self.bg:SetColorTexture(color.r, color.g, color.b)
	end

	self:SetSize((BobUI_Settings["BorderSize"] * 2) + BobUI_Settings["SpellIconSize"], (BobUI_Settings["BorderSize"] * 2) + BobUI_Settings["SpellIconSize"])
	self.Texture:SetSize(BobUI_Settings["SpellIconSize"], BobUI_Settings["SpellIconSize"])
	self.Texture:SetPoint("TOPLEFT", self, "TOPLEFT", BobUI_Settings["BorderSize"], -1 * BobUI_Settings["BorderSize"])
	self.Texture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1 * BobUI_Settings["BorderSize"], BobUI_Settings["BorderSize"])

	-- self.milestoneID
	-- self.(arrow?)
end

function BobUI_HeartEssenceSlotMixin:OnEnter()
	if self.essenceID ~= nil then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetAzeriteEssenceSlot(C_AzeriteEssence.GetMilestoneInfo(self.milestoneID).slot);
		GameTooltip:Show();
	end
end

function BobUI_HeartEssenceSlotMixin:OnLoad()
    SetClampedTextureRotation(self.Arrow, 90);
	self:RegisterForDrag("LeftButton");
end

function BobUI_HeartEssenceSlotMixin:OnDragStart()
    if self.milestoneID then
        local spellID = C_AzeriteEssence.GetMilestoneSpell(self.milestoneID);

        if spellID then
            PickupSpell(spellID);
        end
    end
end

function BobUI_HeartEssenceSlotMixin:OnClick(mouseButton)
	if mouseButton == "LeftButton" then
		local linkedToChat = false;
		if ( IsModifiedClick("CHATLINK") ) then
			linkedToChat = HandleModifiedItemClick(C_AzeriteEssence.GetEssenceHyperlink(self.essenceID, self.rank));
		end
		if ( not linkedToChat ) then
            if SELECTED_HEART_ESSENCE_SLOT ~= nil then SELECTED_HEART_ESSENCE_SLOT.Arrow:Hide() end

            if SELECTED_HEART_ESSENCE_SLOT == self then
                SELECTED_HEART_ESSENCE_SLOT.Arrow:Hide();
                SELECTED_HEART_ESSENCE_SLOT:GetParent().essenceList:Hide()
                SELECTED_HEART_ESSENCE_SLOT = nil
            else
                SELECTED_HEART_ESSENCE_SLOT = self
                SELECTED_HEART_ESSENCE_SLOT.Arrow:Show();
                SELECTED_HEART_ESSENCE_SLOT:GetParent().essenceList:Show()
            end
        
            local TalentFrame = self:GetParent()
        
            local TalentFrameHeight = ((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2)) * 7) + BobUI_Settings["FontSizeBody"] + 30 + 2
            
            if TalentFrame.essenceList:IsShown() then
                TalentFrame:SetSize(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2) + (((BobUI_Settings["BorderSize"] * 2) + BobUI_Settings["SpellIconSize"]) * 3 + 4)) + 10 + 20), TalentFrameHeight)
            else
                TalentFrame:SetSize(TalentFrame.titleFrame.category:GetWidth() + 10, TalentFrameHeight)
            end
        
            resizeBackground() 
		end
	end

end

BobUI_HeartEssenceButtonMixin = {}

function BobUI_HeartEssenceButtonMixin:OnEnter() 
	if self.essenceID ~= nil then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetAzeriteEssence(self.essenceID, self.rank);
		GameTooltip:Show();
	end
end

function BobUI_HeartEssenceButtonMixin:OnShow()
	if self.rank ~= nil then
		local color = ITEM_QUALITY_COLORS[self.rank + 1];
		self.bg:SetColorTexture(color.r, color.g, color.b)
	end

	self:SetSize((BobUI_Settings["BorderSize"] * 2) + BobUI_Settings["SpellIconSize"], (BobUI_Settings["BorderSize"] * 2) + BobUI_Settings["SpellIconSize"])
	self.Texture:SetSize(BobUI_Settings["SpellIconSize"], BobUI_Settings["SpellIconSize"])
	self.Texture:SetPoint("TOPLEFT", self, "TOPLEFT", BobUI_Settings["BorderSize"], -1 * BobUI_Settings["BorderSize"])
	self.Texture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1 * BobUI_Settings["BorderSize"], BobUI_Settings["BorderSize"])
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function BobUI_HeartEssenceButtonMixin:OnClick(mouseButton)
	if mouseButton == "LeftButton" then
		local linkedToChat = false;
		if ( IsModifiedClick("CHATLINK") ) then
			linkedToChat = HandleModifiedItemClick(C_AzeriteEssence.GetEssenceHyperlink(self.essenceID, self.rank));
		end
		if ( not linkedToChat ) then
			if SELECTED_HEART_ESSENCE_SLOT.milestoneID ~= nil then
				C_AzeriteEssence.ActivateEssence(self.essenceID, SELECTED_HEART_ESSENCE_SLOT.milestoneID)
				
				SELECTED_HEART_ESSENCE_SLOT:OnClick("LeftButton")
			end
		end
	elseif mouseButton == "RightButton" then
		if BobTabPage2:IsShown() then

			local heartData = {SELECTED_HEART_ESSENCE_SLOT.milestoneID, self.essenceName}

			SELECTED_HEART_PRESET_DATA[tonumber(SELECTED_HEART_ESSENCE_SLOT.slot)] = heartData
			updatePresetData()
		end
	end

end