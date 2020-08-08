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