local BobUI = ((BobUI == nil) and CreateFrame("Frame") or BobUI)
HideFrames = CreateFrame("Frame", UIParent) -- hidden frame to inherit blizzard spellbook/talent frames as children, to hide them.

BobUI:RegisterEvent("PLAYER_ENTERING_WORLD")
BobUI:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
BobUI:RegisterEvent("SPELLS_CHANGED");
BobUI:RegisterEvent("SPELL_UPDATE_COOLDOWN");
BobUI:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
BobUI:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
BobUI:RegisterEvent("PET_BAR_UPDATE");
BobUI:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
BobUI:RegisterEvent("PLAYER_PVP_TALENT_UPDATE");
BobUI:RegisterEvent("ADDON_LOADED");
BobUI:RegisterEvent("UNIT_MODEL_CHANGED");
BobUI:RegisterEvent("UNIT_LEVEL");
BobUI:RegisterEvent("LEARNED_SPELL_IN_TAB");
BobUI:RegisterEvent("PLAYER_TALENT_UPDATE");
BobUI:RegisterEvent("PET_SPECIALIZATION_CHANGED");
BobUI:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
BobUI:RegisterEvent("PLAYER_LEARN_TALENT_FAILED");
BobUI:RegisterEvent("PLAYER_LEVEL_CHANGED");
BobUI:RegisterEvent("PLAYER_FLAGS_CHANGED");
BobUI:RegisterEvent("ZONE_CHANGED");
BobUI:RegisterEvent("ZONE_CHANGED_NEW_AREA");
BobUI:RegisterEvent("AZERITE_ESSENCE_ACTIVATED")
BobUI:RegisterEvent("PLAYER_REGEN_DISABLED")
BobUI:RegisterEvent("PLAYER_REGEN_ENABLED")
BobUI:RegisterEvent("SKILL_LINES_CHANGED");
BobUI:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");

function BobUI_events(self, event, ...)

    if event == "PLAYER_REGEN_DISABLED" then
        if BobUI_AbilityTab:IsShown() then
            BobUI_Globals["SHOW_BOBUI_ABILITY_TAB_AFTER_COMBAT"] = true
            BobUI_AbilityTab:Hide()
        else
            BobUI_Globals["SHOW_BOBUI_ABILITY_TAB_AFTER_COMBAT"] = false
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if BobUI_Globals["SHOW_BOBUI_ABILITY_TAB_AFTER_COMBAT"] then
        BobUI_AbilityTab:Show()
        end

    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then

        if event == "PLAYER_SPECIALIZATION_CHANGED" and BobUI_Globals["CHARACTER"]["currentSpecializationIndex"] ~= nil then
            if BobUI_Globals["CHARACTER"]["currentSpecializationIndex"] ~= GetSpecialization() then
                BobUI_Globals["VIEWED_SPELL_BOOK"] = 2
                BobUI_Globals["VIEWED_SPELL_BOOK_NUM_SPELLS"] = GetNumSpellsForSpellBook(BobUI_Globals["VIEWED_SPELL_BOOK"])
            end
        end

        GetCurrentCharacterInfo()
        SetupBobUISettings()
        
        BobUI_UpdateProfessions()
        BobUI_PlayerTalentFrameTalents_OnLoad()
        BobUI_PvpTalentFrame_OnLoad()

        if BobUI_Globals["LOADED"] == false then
            BobUI_AbilityTab_OnLoad()
            BobUI_Globals["LOADED"] = true
        end
        BobUI_TabTitle.text:SetText(SPECIALIZATION .. ": " .. BobUI_Globals["CHARACTER"]["currentSpecializationName"])
    elseif event == "SPELLS_CHANGED" then
        if BobUI_AbilityTab:IsShown() then
            BobUI_UpdateProfessions()
            SpecButton_OnShow(BobUI_specButtons.specButton6)

            createSpellButtons()
            updateSpellButtons()
            updateSpellBookLabel()

            specButtonsUpdateBorders()
            resizeBackground() 
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if BobUI_Globals["LOADED"] == true then
            if BobUI_AbilityTab:IsShown() then
                displayHeartEssenceSlots()
            end
        end
    elseif event == "AZERITE_ESSENCE_ACTIVATED" then
		setupHeartEssences(BobUI_PLayerTalentFrameTalentsEssences)
    end
end

function BobUI_AbilityTab_OnLoad()
	tinsert(UISpecialFrames, "BobUI_AbilityTab")
	tinsert(UISpecialFrames, "BobUI_SettingsFrame")
	HideFrames:Hide()

	SpellBookFrame:SetParent(HideFrames)

	SpellBookFrame:SetScript("OnShow", function()
		if CliqueShown() == false and (HasPendingGlyphCast() == false and IsPendingGlyphRemoval() == false) then
			if SpellBookFrame:GetParent() ~= HideFrames then SpellBookFrame:SetParent(HideFrames) end
			SpellBookFrame:UnregisterAllEvents();
		end
	end)
	

	hooksecurefunc("TalentFrame_LoadUI", function()
		PlayerTalentFrame:SetParent(HideFrames)
		PlayerTalentFrame:UnregisterAllEvents();
	end)

	hooksecurefunc("ToggleSpellBook", function(bookType)
		if bookType == "professions" then
			if BobUI_Globals["SPELL_BOOK_TYPE"] == "spell" then
				SpecButton7:Click()
				if BobUI_AbilityTab:IsShown() == false then toggleSpellBook() end
			end
		else
			if BobUI_Globals["SPELL_BOOK_TYPE"] == "profession" then
				_G["SpecButton"..(GetSpecialization() + 1)]:Click()
				if BobUI_AbilityTab:IsShown() == false then toggleSpellBook() end
			end
			-- if shown professions, then go to specs spell book
		end
	end)

	hooksecurefunc("ShowUIPanel", function(frame)
		local frameName = frame
		if type(frame) == "table" then frameName = frame:GetName() end

		if frame ~= nil then
			if ((frameName == "SpellBookFrame" and CliqueShown() == false and (HasPendingGlyphCast() == false and IsPendingGlyphRemoval() == false)) or (frameName == "PlayerTalentFrame")) then
				if frame:IsShown() then HideUIPanel(frame) end
				toggleSpellBook()
			else
				if frameName == "SpellBookFrame" then
					SpellBookFrame:SetParent(UIParent)
					SpellBookFrame.bookType = BOOKTYPE_SPELL;
					SpellBookFrame_Update();
				end
			end
		end

	end)

	if BobUI_Globals["VIEWED_SPELL_BOOK"] == nil then
		BobUI_Globals["VIEWED_SPELL_BOOK"] = 2
		BobUI_Globals["VIEWED_TAB_ID"] = GetSpecialization() + 1
	end
	

	BobUI_toggleTabPage(BobTabPage1)

	

end

BobUI:SetScript("OnEvent", function(self, event, ...)
	if not InCombatLockdown() then
        BobUI_events(self, event, ...)
    end
end)


