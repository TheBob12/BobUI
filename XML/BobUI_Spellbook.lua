-- BobUI_Spellbook.lua will eventually be removed and split up into relevant files.


function modifiedClick(spellIndex, button)
	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrameText and MacroFrameText:HasFocus() ) then
			local spellName, subSpellName = GetSpellBookItemName(spellIndex, BobUI_Globals["SPELL_BOOK_TYPE"]);
			if ( spellName and not IsPassiveSpell(spellIndex, BobUI_Globals["SPELL_BOOK_TYPE"]) ) then
				if ( subSpellName and (strlen(subSpellName) > 0) ) then
					ChatEdit_InsertLink(spellName.."("..subSpellName..")");
				else
					ChatEdit_InsertLink(spellName);
				end
			end
			return;
		else
			local tradeSkillLink, tradeSkillSpellID = GetSpellTradeSkillLink(spellIndex, BobUI_Globals["SPELL_BOOK_TYPE"]);
			if ( tradeSkillSpellID ) then
				ChatEdit_InsertLink(tradeSkillLink);
			else
				local spellLink = GetSpellLink(spellIndex, BobUI_Globals["SPELL_BOOK_TYPE"]);
				ChatEdit_InsertLink(spellLink);
			end
			return;
		end
	end
end

function UpdateCooldown(self, slot, slotType)
	
	if (slot) then

		local start, duration, enable, modRate = GetSpellCooldown(slot, slotType);

		if (self.cooldown and start and duration) then
			if (enable) then
				self.cooldown:Hide();
				self.cooldown.coolDownTimer:Hide();
			else
				self.cooldown:Show();
				self.cooldown.coolDownTimer:SetText((duration + start) - GetTime())
				self.cooldown.coolDownTimer:Show();
			end

			CooldownFrame_Set(self.cooldown, start, duration, enable, true, modRate);
		else
			self.cooldown:Hide();
			self.cooldown.coolDownTimer:Hide();
		end
	end
end


function BobUI_spellBookItemData(i)
	local offset = 0;
	local numFlyoutSpells = 0
	local professionIndex = 0

	local _
			
	if BobUI_Globals["SPELL_BOOK_TYPE"] == "profession" then
		offset, isFirstOfProfession, professionIndex = getProfessionOffset(i)
	elseif BobUI_Globals["SPELL_BOOK_TYPE"] == "spell" then
		_, _, offset = GetSpellTabInfo(BobUI_Globals["VIEWED_SPELL_BOOK"]);
	end

	local texture = GetSpellBookItemTexture(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"]);
	local spellType, actionID = GetSpellBookItemInfo(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"]);
	local spellName, subSpellName, spellID = GetSpellBookItemName(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"])
	local autoCastAllowed, autoCastEnabled = nil, nil;
	local isPassive
	local isOnActionbar = (BobUI_Globals["VIEWED_SPELL_BOOK"] ~= 2 and true or C_ActionBar.IsOnBarOrSpecialBar(actionID))
	local spellLevel = GetSpellAvailableLevel(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"])

	if (BobUI_Globals["SPELL_BOOK_TYPE"] == "pet") then
		isOnActionbar = C_ActionBar.HasPetActionButtons(actionID) or C_ActionBar.HasPetActionPetBarIndices(actionID);
	end

	if (BobUI_Globals["SPELL_BOOK_TYPE"] == "profession") then 
		isPassive = false 
	else 
		isPassive = IsPassiveSpell(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"]) 
	end

	if spellType == "FLYOUT" then
		numFlyoutSpells = select(3, GetFlyoutInfo(actionID))
	end

	if BobUI_Globals["SPELL_BOOK_TYPE"] == "pet" then
		autoCastAllowed, autoCastEnabled = GetSpellAutocast(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"])
	end

	return offset, isFirstOfProfession, isPassive, isOnActionbar, texture, spellType, numFlyoutSpells, actionID, spellName, subSpellName, spellID, spellLevel, autoCastAllowed, autoCastEnabled, professionIndex
end

function AssignScriptsToButtons(button, i, offset, missingOnActionBar, spellID, spellName, actionID, autoCastAllowed)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	button:SetScript("OnEnter", function()
		GameTooltip:Hide()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		
		if spellID then
			GameTooltip:SetSpellByID(spellID)
		else
			GameTooltip:SetSpellBookItem(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"])
		end

		GameTooltip:AddLine(missingOnActionBar and SPELLBOOK_SPELL_NOT_ON_ACTION_BAR or "",LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
		GameTooltip:Show()
	end)

	button:SetScript("OnDragStart", function()
		 -- To do: Shouldn't be allowed to PickupSpell from other specs.
			if spellID and BobUI_Globals["SPELL_BOOK_TYPE"] ~= "pet" then
				if i+offset ~= 0 then
					if not IsPassiveSpell(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"]) then
						PickupSpell(getCorrectSpellIDForDrag(spellID))
					end
				else
					PickupSpell(getCorrectSpellIDForDrag(spellID))
				end
			else
				PickupSpellBookItem(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"])
			end
	end)

	button:RegisterEvent("SPELLS_CHANGED")
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", function(self, event, ...)
		if event == "SPELL_UPDATE_COOLDOWN" or event == "SPELLS_CHANGED" then
			UpdateCooldown(self, i+offset, BobUI_Globals["SPELL_BOOK_TYPE"])
		end
	end)

	if BobUI_Globals["SPELL_BOOK_TYPE"] == "pet" then 
		if (spellID ~= nil) then
			if autoCastAllowed then
				button:RegisterForClicks("AnyUp")
				button:SetAttribute("type2", "macro");
				button:SetAttribute("macrotext", "/petautocasttoggle "..spellName);
			end
				button:SetAttribute("type1", "spell");
				button:SetAttribute("spell", spellID);
		else
			if spellName == "Defensive" then
				button:SetAttribute("type1", "macro");
				button:SetAttribute("macrotext", "/petdefensive"); -- doesn't work, not sure how to fix. 
			elseif spellName == "Move To" then
				button:SetAttribute("type1", "macro");
				button:SetAttribute("macrotext", "/petmoveto");
			else
				
				button:SetAttribute("type1", "macro");
				button:SetAttribute("macrotext", "/pet"..spellName);
			end
				
		end
	else 
		button:SetAttribute("type1", "spell");
		button:SetAttribute("spell", actionID);
		button:SetAttribute("target", "target");
	end
end



function toggleAutocastShine(button, bIndex)
	local autoCastableTexture = _G[button:GetName().."AutoCastable"];
	local petAutoCastShine = _G[button:GetName().."Shine"];
	
	autoCastableTexture:Hide();

	if BobUI_Globals["SPELL_BOOK_TYPE"] ~= "pet" then AutoCastShine_AutoCastStop(petAutoCastShine); return end

	local autoCastAllowed, autoCastEnabled = GetSpellAutocast(bIndex, BobUI_Globals["SPELL_BOOK_TYPE"])

	if ( autoCastAllowed ) then
		autoCastableTexture:Show();
	end
	
	if autoCastEnabled then
		AutoCastShine_AutoCastStart(petAutoCastShine)
	else
		AutoCastShine_AutoCastStop(petAutoCastShine)
	end
end

function updateSpellButtons()

	BobTabPage1:SetWidth(9 * BobUI_Settings["SpellIconSize"] + (8*4))
	--BobTabPage2:SetWidth(BobTabPage1:GetWidth())
	BobTabPage1Actives:SetWidth(BobTabPage1:GetWidth())
	BobTabPage1Passives:SetWidth(BobTabPage1:GetWidth())
	BobTabPage1FlyoutButtons:SetWidth(BobTabPage1:GetWidth())
	BobTabPage1PetControlsAndFlyouts:SetWidth(BobTabPage1:GetWidth())

	BobTabPage1Actives:SetPoint("TOPLEFT", BobTabPage1Actives:GetParent(), "TOPLEFT", 0, -1 * BobUI_Settings["FontSizeBody"])
	BobTabPage1Actives.category:SetPoint("TOPLEFT", BobTabPage1Actives, "TOPLEFT", 0, BobUI_Settings["FontSizeBody"])

	BobTabPage1Passives:SetPoint("TOPLEFT", BobTabPage1Actives, "BOTTOMLEFT", 0, (-1 * BobUI_Settings["FontSizeBody"]) - 10)
	BobTabPage1Passives.category:SetPoint("TOPLEFT", BobTabPage1Passives, "TOPLEFT", 0, BobUI_Settings["FontSizeBody"])

	BobUI_PlayerTalentFrameTalentsTalents:SetPoint("TOPLEFT", BobUI_PlayerTalentFrameTalentsTalents:GetParent().borderLeft, "TOPLEFT", 10, (-1 * BobUI_Settings["FontSizeBody"]) - 5)
	BobUI_PlayerTalentFrameTalentsTalents.category:SetPoint("TOPLEFT", BobUI_PlayerTalentFrameTalentsTalents, "TOPLEFT", BobUI_Settings["SeparatorSize"], BobUI_Settings["FontSizeBody"])
	BobUI_PlayerTalentFrameTalentsTalentRow1:SetPoint("LEFT", BobUI_PlayerTalentFrameTalentsTalents, "LEFT", BobUI_Settings["SeparatorSize"], 0)

	BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFramePVPTalents:SetPoint("TOPLEFT", BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFramePVPTalents:GetParent(), "TOPLEFT", 10, (-1 * BobUI_Settings["FontSizeBody"]))
	BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFramePVPTalents.category:SetPoint("TOPLEFT", BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFramePVPTalents, "TOPLEFT", 0, BobUI_Settings["FontSizeBody"])

	BobUI_HeartEssencesTitle:SetPoint("TOPLEFT", BobUI_HeartEssences, "TOPLEFT", 10, (-1 * BobUI_Settings["FontSizeBody"]))
	BobUI_HeartEssencesTitle.category:SetPoint("TOPLEFT", BobUI_HeartEssencesTitle, "TOPLEFT", 0, BobUI_Settings["FontSizeBody"])



	if BobUI_Globals["VIEWED_SPELL_BOOK"] == 7 then 
		BobUI_Globals["SPELL_BOOK_TYPE"] = "pet"
	elseif BobUI_Globals["VIEWED_SPELL_BOOK"] == 8 then 
		BobUI_Globals["SPELL_BOOK_TYPE"] = "profession"
	else
		BobUI_Globals["SPELL_BOOK_TYPE"] = "spell"
	end


	local newLineAt = 9;

	if not BobTabPage1.buttons then
		return
	end


	local j = 1
	local k = 1
	local l = 1
	local m = 1
	local vCi= 1
	local unlearnProfession = 0

	local startOfLinePassives = nil
	local startOfLineActives = nil
	local startOfLinePetControls = nil
	local startOfLineFlyouts = nil

	local lastPassive = nil
	local lastActive = nil
	local lastPetControl = nil
	local lastFlyout = nil

	local LastFirstOfProfession = nil

	BobTabPage1Passives:SetHeight(40)
	BobTabPage1Actives:SetHeight(0)
	BobTabPage1PetControlsAndFlyouts:SetHeight(0)
	BobTabPage1FlyoutButtons:SetHeight(40)

	for i = 1, #BobTabPage1.buttons do 
		local button = BobTabPage1.buttons[i];
		button:Hide(); 
		button.FlyoutArrow:Hide()
		button.TrainBook:Hide()
		_G[button:GetName().."RequiredLevelString"]:SetFont(BobUI_Settings["FontType"], BobUI_Settings["FontSizeBody"], "OUTLINE")
		_G[button:GetName().."RequiredLevelString"]:SetTextColor(0.8,0.8,0.8,1)
		_G[button:GetName().."RequiredLevelString"]:SetText()
		_G[button:GetName().."IconTexture"]:SetDesaturated(false)
		_G[button:GetName().."RequiredLevelString"]:Hide()

		if i <= BobUI_Globals["VIEWED_SPELL_BOOK_NUM_SPELLS"] then
			local offset, isFirstOfProfession, isPassive, isOnActionbar, texture, spellType, numFlyoutSpells, actionID, spellName, subSpellName, spellID, spellLevel, autoCastAllowed, autoCastEnabled, professionIndex = BobUI_spellBookItemData(i)

			toggleAutocastShine(button, i+offset)

			if (spellType == "FLYOUT") then
				button.FlyoutArrow:Show()
				SetClampedTextureRotation(button.FlyoutArrow, 180);
				isOnActionbar = true
			end

			local missingOnActionBar = ((isOnActionbar ~= true) and (isPassive ~= true))
			
			local isDisabled = spellID and C_SpellBook.IsSpellDisabled(spellID);
			
			--- change this at some point... I guess


			
			if spellType == "FUTURESPELL" then
				missingOnActionBar = false

				if (spellLevel and spellLevel > UnitLevel("player") or isDisabled) then
					_G[button:GetName().."RequiredLevelString"]:SetText("Lv "..spellLevel)
					_G[button:GetName().."RequiredLevelString"]:Show()
				else
					button.TrainBook:Show()
				end

				_G[button:GetName().."IconTexture"]:SetDesaturated(true)
			end
				
			if missingOnActionBar then button.SpellHighlightTexture:Show() else button.SpellHighlightTexture:Hide() end

			local newLinePassives = (math.fmod(j-1,newLineAt) == 0)
			local newLineActives = (math.fmod(k-1,newLineAt) == 0)
			local newLinePetControls = (math.fmod(l-1,newLineAt) == 0)
			local newLineFlyouts = (math.fmod(m-1,newLineAt) == 0)

			button:ClearAllPoints()
			if spellType == "FLYOUT" then
				if m - 1 == 0 then
					button:SetPoint("TOPLEFT", BobTabPage1PetControlsAndFlyouts, "TOPLEFT", 0, 0);
				else
					if (newLineFlyouts) then
						button:SetPoint("TOPLEFT", startOfLineFlyouts, "BOTTOMLEFT", 0,-4);
					end
				end
				if newLineFlyouts then
					startOfLineFlyouts = BobTabPage1.buttons[i]
					BobTabPage1PetControlsAndFlyouts:SetHeight(BobTabPage1PetControlsAndFlyouts:GetHeight() + BobUI_Settings["SpellIconSize"] + 4)
				else
					button:SetPoint("LEFT", lastFlyout or startOfLineFlyouts, "RIGHT", 4, 0);
				end
				lastFlyout = BobTabPage1.buttons[i]

			else
				if isPassive then

					if j - 1 == 0 then
						button:SetPoint("TOPLEFT", BobTabPage1Passives, "TOPLEFT", 0, 0);
					else
						if (newLinePassives) then
							button:SetPoint("TOPLEFT", startOfLinePassives, "BOTTOMLEFT", 0,-4);
						end
					end
					if newLinePassives then
						startOfLinePassives = BobTabPage1.buttons[i]
						BobTabPage1Passives:SetHeight(BobTabPage1Passives:GetHeight() + BobUI_Settings["SpellIconSize"] + 4)
					else
						button:SetPoint("LEFT", lastPassive or startOfLinePassives, "RIGHT", 4, 0);
					end
					lastPassive = BobTabPage1.buttons[i]

				else
					if spellID == nil and BobUI_Globals["SPELL_BOOK_TYPE"] == "pet" then
						if l - 1 == 0 then
							button:SetPoint("TOPLEFT", BobTabPage1PetControlsAndFlyouts, "TOPLEFT", 0, 0);
						else
							if (newLinePetControls) then
								button:SetPoint("TOPLEFT", startOfLinePetControls, "BOTTOMLEFT", 0,-4);
							end
						end
						if newLinePetControls then
							startOfLinePetControls = BobTabPage1.buttons[i]
							BobTabPage1PetControlsAndFlyouts:SetHeight(BobTabPage1PetControlsAndFlyouts:GetHeight() + BobUI_Settings["SpellIconSize"] + 4)
						else
							button:SetPoint("LEFT", lastPetControl or startOfLinePetControls, "RIGHT", 4, 0);
						end
						lastPetControl = BobTabPage1.buttons[i]
					else
						if k - 1 == 0 then
							button:SetPoint("TOPLEFT", BobTabPage1Actives, "TOPLEFT", 0, 0);
						else
							if (newLineActives) then
								button:SetPoint("TOPLEFT", startOfLineActives, "BOTTOMLEFT", 0,-4);
							end
						end
						if newLineActives then
							startOfLineActives = BobTabPage1.buttons[i]
							BobTabPage1Actives:SetHeight(BobTabPage1Actives:GetHeight() + BobUI_Settings["SpellIconSize"] + 4)
						else
							button:SetPoint("LEFT", lastActive or startOfLineActives, "RIGHT", 4, 0);
						end
						lastActive = BobTabPage1.buttons[i]
					end

				end
			end

			AssignScriptsToButtons(button, i, offset, missingOnActionBar, spellID, spellName, actionID, autoCastAllowed)
			
			button:SetScript("OnMouseUp", function(self, mBtn)
				if ( IsModifiedClick() ) then
					modifiedClick(i+offset, mBtn)
				else
					if (spellType == "FLYOUT") then -----------
						local startPt = BobUI_Globals["VIEWED_SPELL_BOOK_NUM_SPELLS"] + 1
						local previousButton = nil
						local newLineBtn = nil
						local btnCount = 1
						if BobUI_Globals["CURRENT_FLYOUT"] == actionID then
							for x1 = startPt, #BobTabPage1.buttons do 
								BobTabPage1.buttons[x1]:Hide()
							end
							BobUI_Globals["CURRENT_FLYOUT"] = nil
						else
							BobUI_Globals["CURRENT_FLYOUT"] = actionID

							for x1 = startPt, #BobTabPage1.buttons do 
								local flyoutButton = BobTabPage1.buttons[x1]
								flyoutButton:ClearAllPoints()

								if x1 > startPt + numFlyoutSpells - 1 then
									flyoutButton:Hide()
								else

									local flyoutSpellID, flyoutOverrideSpellID, flyoutIsKnown, flyoutSpellName, flyoutSlotSpecID = GetFlyoutSlotInfo(actionID, (x1-startPt)+1);
									

									if flyoutIsKnown then
										if previousButton == nil then
											flyoutButton:SetPoint("TOPLEFT", BobTabPage1FlyoutButtons, "TOPLEFT", 0, 0);
											newLineBtn = flyoutButton
										elseif btnCount == 8 then
											flyoutButton:SetPoint("TOPLEFT", newLineBtn, "BOTTOMLEFT", 0, -2);
											btnCount = 1
											newLineBtn = flyoutButton
										else
											flyoutButton:SetPoint("LEFT", previousButton, "RIGHT", 2, 0);
										end
										
										AssignScriptsToButtons(flyoutButton, 0, 0, false, flyoutSpellID, flyoutSpellName, flyoutSpellID, autoCastAllowed)

										previousButton = BobTabPage1.buttons[x1]
										btnCount = btnCount + 1

										_G[flyoutButton:GetName().."IconTexture"]:SetTexture(GetSpellBookItemTexture(flyoutSpellName))
										_G[flyoutButton:GetName().."IconTexture"]:Show()
										flyoutButton:SetSize(30,30)
										flyoutButton:Show()
									else
										flyoutButton:Hide()
									end
								end
							end
						end
					elseif (mBtn == "RightButton" and BobUI_Globals["SPELL_BOOK_TYPE"] == "pet") then
						
						BobUI_wait(0.2, toggleAutocastShine, button, i+offset)
					end
				end
			end)
			

			
			
			_G[button:GetName().."IconTexture"]:SetTexture(texture)
			_G[button:GetName().."IconTexture"]:Show()
			button.cooldown:Hide();
			button.cooldown.coolDownTimer:Hide();
			button.unlearn:Hide()
			button.profText:Hide()
			button.AbilityHighlight:Hide();
			button.AbilityHighlightAnim:Stop();
			button:SetSize(BobUI_Settings["SpellIconSize"], BobUI_Settings["SpellIconSize"])




			if BobUI_Globals["SPELL_BOOK_TYPE"] == "profession" then
				if isFirstOfProfession then
					
					if (LastFirstOfProfession == nil) then
						button:SetPoint("TOPLEFT", BobTabPage1Actives, "TOPLEFT", 0, 0);
					else
						button:SetPoint("TOPLEFT", LastFirstOfProfession, "BOTTOMLEFT", 0, -4);
					end

					button:SetSize(BobUI_Settings["SpellIconSize"] * 1.25, BobUI_Settings["SpellIconSize"] * 1.25)
					button.profText:SetFont(BobUI_Settings["FontType"], BobUI_Settings["FontSizeBody"])
					button.profText:SetText(BobUI_Globals["PROFESSIONS"][professionIndex]["name"] .. "\n" .. BobUI_Globals["PROFESSIONS"][professionIndex]["rank"] .. "/" .. BobUI_Globals["PROFESSIONS"][professionIndex]["maxRank"])
					button.profText:SetPoint("LEFT", button, "RIGHT", BobUI_Settings["SpellIconSize"] + 8, 0);
					button.profText:Show()
					button.unlearn:SetScript("OnClick", function()
						StaticPopup_Show("UNLEARN_SKILL", BobUI_Globals["PROFESSIONS"][professionIndex]["name"], nil, BobUI_Globals["PROFESSIONS"][professionIndex]["skillLine"]);
					end)
				end

				if ((professionIndex == 1 or professionIndex == 2) and isFirstOfProfession) then
					button.unlearn:Show()
				end
				
				if isFirstOfProfession then
					LastFirstOfProfession = BobTabPage1.buttons[i]
				end
			end

			button:Show(); 
			

			if isPassive then j = j + 1; elseif spellID == nil and BobUI_Globals["SPELL_BOOK_TYPE"] == "pet" then l = l + 1 elseif spellType == "FLYOUT" then m = m + 1 else k = k + 1 end
		end
	end

	if BobTabPage1Passives:GetHeight() > 40 then
		BobTabPage1Passives:SetHeight(BobTabPage1Passives:GetHeight() - 40)
	end
end

function BobUI_GetNumSpellsForSpellBook(tabIndex)
	local specName, texture, offset, numSpells = GetSpellTabInfo(tabIndex)

	if BobUI_Globals["VIEWED_SPELL_BOOK"] == 7 then return GetNumSpellsForSpellBook(6) end
	if tabIndex > 7 then return GetNumSpellsForSpellBook(7) end

	return numSpells
end

function createSpellButtons()
	if BobUI_Globals["CHARACTER"]["classID"] == nil then return end
	local button;
	local numFlyoutSpells = 0

	if not BobTabPage1.buttons then
		BobTabPage1.buttons = {}
	end

	local _, _, offset = GetSpellTabInfo(BobUI_Globals["VIEWED_SPELL_BOOK"]);

	-- creates flyout buttons
	for i = 1, BobUI_Globals["VIEWED_SPELL_BOOK_NUM_SPELLS"] do
		local spellType, actionID = GetSpellBookItemInfo(i+offset, BobUI_Globals["SPELL_BOOK_TYPE"]);
		if spellType == "FLYOUT" then
			local numCurrentFlyoutSpells = select(3, GetFlyoutInfo(actionID))

			if numFlyoutSpells < numCurrentFlyoutSpells then
				numFlyoutSpells = numCurrentFlyoutSpells
			end
		end
	end

	local numSpecs = GetNumSpecializationsForClassID(BobUI_Globals["CHARACTER"]["classID"]);

	local numButtonsToCreate = 0

	for i=1, numSpecs+2 do
		if BobUI_GetNumSpellsForSpellBook(i) > numButtonsToCreate then numButtonsToCreate = BobUI_GetNumSpellsForSpellBook(i) end
	end

	-- create spell buttons
	for i = #BobTabPage1.buttons + 1, numButtonsToCreate + numFlyoutSpells do 

		button = CreateFrame("Button", "abilityButton"..i, BobTabPage1, "BobUI_SpellButtonTemplate,SecureActionButtonTemplate");
		button:SetSize(32,32)
		button:RegisterForDrag("LeftButton");

		tinsert(BobTabPage1.buttons, button)
	end
	
end

function specButtonsUpdateBorders()

	local numSpecs = GetNumSpecializationsForClassID(BobUI_Globals["CHARACTER"]["classID"]);
	local currentSpecID = GetSpecialization()
	

	local lastShownButton = nil

	for i=0,8 do
		local button = BobUI_specButtons["specButton"..i];

		if (i == currentSpecID+1) then
			button.bg:SetColorTexture(GetBorderColor("BorderColorActive"))
		else
			if button:GetID() == BobUI_Globals["VIEWED_TAB_ID"] then
				button.bg:SetColorTexture(GetBorderColor("BorderColorSelected"))
			else
				button.bg:SetColorTexture(0.1, 0.1, 0.1, 1)
			end
		end

		if button:IsShown() then
			if lastShownButton ~= nil then
				button:SetPoint("TOPLEFT", lastShownButton, "TOPRIGHT", 5, 0)
			end

			lastShownButton = button
		else
			if i < 8 then
				local nextButton = _G["SpecButton" .. i+1]
				nextButton:SetPoint("TOPLEFT", lastShownButton, "TOPRIGHT", 5, 0)
			end
		end
	end

end


function SpecButton_OnShow(self)
	if BobUI_Globals["CHARACTER"]["classID"] == nil then return end

	local numSpecs = GetNumSpecializationsForClassID(BobUI_Globals["CHARACTER"]["classID"]);
	

	local numTabs = 3 + numSpecs + (PetHasSpellbook() and 1 or 0) -- general tab, class tab & crafting tab + num specs + pet spells?


	self:SetSize(BobUI_Settings["TabIconSize"] + (BobUI_Settings["BorderSize"] * 2), BobUI_Settings["TabIconSize"] + (BobUI_Settings["BorderSize"] * 2))
	self.specIcon:SetSize(BobUI_Settings["TabIconSize"], BobUI_Settings["TabIconSize"])
	self:Show();
	
	if self:GetID() == 0 then
			local spellBookName, spellBookTexture = GetSpellTabInfo(2)
			self.specIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES");
			self.specIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[BobUI_Globals["CHARACTER"]["classFileName"]]))
			self.roleIcon:Hide();
			self.tooltip = spellBookName

	elseif self:GetID() == 1 then
		local spellBookName, spellBookTexture = GetSpellTabInfo(1)
			self.specIcon:SetTexture(136830)
			self.roleIcon:Hide();
			self.tooltip = spellBookName

	elseif self:GetID() <= 1+numSpecs then
			local specID, specName, specDescription, specIcon, specRole, mainStat = GetSpecializationInfo(self:GetID()-1) 
			
			self.specIcon:SetTexture(specIcon);
			
			self.tooltip =  specName .. " " .. BobUI_Globals["CHARACTER"]["className"] ..  "\n\n" .. specDescription .. "\n\n" .. ROLE .. ": " .. BobUI_Globals["roleNames"][specRole];
			self.roleIcon:SetTexCoord(GetTexCoordsForRole(specRole));
	elseif self:GetID() > numSpecs and self:GetID() < 6 then
			self:Hide();
	
	elseif self:GetID() == 6 then
		local hasPetSpells, petToken = HasPetSpells();

		if ( hasPetSpells and PetHasSpellbook() ) then
			self.specIcon:SetTexture("Interface/Icons/ABILITY_HUNTER_SICKEM");
			self.roleIcon:Hide();
		else
			if BobUI_Globals["VIEWED_SPELL_BOOK"] == 7 then BobUI_Globals["VIEWED_SPELL_BOOK"] = 2 end
			self:Hide();
		end
	elseif self:GetID() == 7 then
			self.roleIcon:Hide();
			self.tooltip = TRADE_SKILLS
	elseif self:GetID() == 8 then
			self.specIcon:SetTexture("Interface/Icons/INV_Jewelry_Trinket_16");
			self.roleIcon:Hide();
			self.tooltip = TALENTS
	end

		BobUI_Globals["VIEWED_SPELL_BOOK_NUM_SPELLS"] = BobUI_GetNumSpellsForSpellBook(BobUI_Globals["VIEWED_SPELL_BOOK"])

		specButtonsUpdateBorders()

end

function SpecButton_OnDoubleClick(self) 
	local numSpecs = GetNumSpecializationsForClassID(BobUI_Globals["CHARACTER"]["classID"]);
	if self:GetID() < 2 or self:GetID() > numSpecs+1 or self:GetID()-1 == GetSpecialization() then return end -- can't change specialization to general spell book or pet/profession. 

	BobUI_Globals["VIEWED_SPELL_BOOK"] = self:GetID()
	SetSpecialization(self:GetID()-1)
end

function SpecButton_OnClick(self)
	BobUI_Globals["VIEWED_TAB_ID"] = self:GetID()
	
	if self:GetID() == 8 then
		BobUI_toggleTabPage(BobTabPage2)
	else
		BobUI_toggleTabPage(BobTabPage1)
		local numSpecs = GetNumSpecializationsForClassID(BobUI_Globals["CHARACTER"]["classID"]);

		local specs = {}

		table.insert(specs, 1)
		specs[0] = 2

		for i=3, numSpecs+2 do -- current specialization is always number 3 spell book.. so need to rearrange books
			if (i < (GetSpecialization()+2)) then
				table.insert(specs, i + 1)
			elseif (i > (GetSpecialization()+2)) then
				table.insert(specs, i)
			else
				table.insert(specs, 3)
			end
		end

		if self:GetID() <= 5 then 
			BobUI_Globals["VIEWED_SPELL_BOOK"] = specs[self:GetID()]
		else 
			BobUI_Globals["VIEWED_SPELL_BOOK"] = self:GetID() + 1
		end

		BobUI_Globals["VIEWED_SPELL_BOOK_NUM_SPELLS"] = BobUI_GetNumSpellsForSpellBook(BobUI_Globals["VIEWED_SPELL_BOOK"])
		BobUI_Globals["CURRENT_FLYOUT"] = nil

		createSpellButtons()
		updateSpellButtons()
		updateSpellBookLabel()
	end

	specButtonsUpdateBorders()
	resizeBackground() 
end

function updateSpellBookLabel()
	if BobUI_Globals["VIEWED_SPELL_BOOK"] < 7 then
		BobTabPage1Actives.category:SetText(GetSpellTabInfo(BobUI_Globals["VIEWED_SPELL_BOOK"]))
	elseif BobUI_Globals["VIEWED_SPELL_BOOK"] == 7 then
		BobTabPage1Actives.category:SetText(PET)
	elseif BobUI_Globals["VIEWED_SPELL_BOOK"] == 8 then
		BobTabPage1Actives.category:SetText(TRADE_SKILLS)
	else
		BobTabPage1Actives.category:SetText()
	end
end

function SpecButton_OnEnter(self)
	if ( not self.selected ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:AddLine(self.tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		if self:GetID() > 1 and self:GetID() < 5 then
			GameTooltip:SetMinimumWidth(300, true);
		end

		GameTooltip:Show();
	end
end

function SpecButton_OnLeave(self)
	GameTooltip:SetMinimumWidth(0, false);
	GameTooltip:Hide();
end

function CliqueShown()
	if CliqueConfig ~= nil then
		return CliqueConfig:IsShown()
	end

	return false
end

function BobUI_toggleTabPage(shown)
	if not InCombatLockdown() then
		BobTabPage1:Hide()
		BobTabPage2:Hide()
		shown:Show()
		BobUI_PlayerTalentFrame:SetPoint("TOPLEFT", shown, "TOPRIGHT", 10, 0)

		if shown == BobTabPage2 then

			BobTabPage2.nameEditBox:SetPoint("TOPLEFT", BobTabPage2, "TOPLEFT", 4, -15)
			BobTabPage2.nameEditBox:SetSize((BobTabPage2NameEditBox.bg:GetWidth() - 4) + BobTabPage2ControlButton2:GetWidth(), BobTabPage2NameEditBox:GetHeight())
			
			BobTabPage2:SetWidth(BobTabPage2.nameEditBox:GetWidth() + 18 + BobTabPage2ScrollFrame:GetWidth() + 22)
			--BobTabPage2ControlButton2:SetPoint("TOPLEFT", BobTabPage2NameEditBox.bg, "TOPRIGHT", 2, 0)
		end

	end
end

function resizeBackground() 
	if BobUI_Globals["LOADED"] == false then return end

	if BobTabPage1:GetHeight() > BobUI_PlayerTalentFrame:GetHeight() then
		BobUI_AbilityTab.bg:SetPoint("BOTTOM", BobTabPage1, "BOTTOM", 0, -10)
	else
		BobUI_AbilityTab.bg:SetPoint("BOTTOM", BobUI_PlayerTalentFrame, "BOTTOM", 0, -10)
	end

	if showHeartEssences()  then 
		if BobUI_HeartEssences.essenceList:IsShown() then
			BobUI_HeartEssences:SetWidth(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2) + (((BobUI_Settings["BorderSize"] * 2) + BobUI_Settings["SpellIconSize"]) * 3 + 4)) + 10 + 20))
		else
			BobUI_HeartEssences:SetWidth(BobUI_HeartEssences.titleFrame.category:GetWidth() + 10)
		end
	end

	BobUI_AbilityTab.bg:SetPoint("RIGHT", (showHeartEssences() and BobUI_HeartEssences or BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame), "RIGHT", 20, 0)

	
	if showHeartEssences()  then 
		BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.borderRight:Show()
		BobUI_HeartEssences:Show()
	else
		BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.borderRight:Hide()
	end

	local frameWidth = (BobTabPage1:IsShown() and BobTabPage1:GetWidth() or BobTabPage2:GetWidth()) + 10 + BobUI_PlayerTalentFrame:GetWidth() + 10 + BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame:GetWidth() + (showHeartEssences() and BobUI_HeartEssences:GetWidth() or 0) + 30
	
	
	BobUI_TabTitle.text:SetFont(BobUI_Settings["FontType"], BobUI_Settings["FontSizeHeader"])

	local titleHeight = max(20, BobUI_Settings["FontSizeHeader"])

	BobUI_TabTitle:SetPoint("RIGHT", BobUI_AbilityTab, "LEFT", frameWidth, 0)
	BobUI_TabTitle:SetPoint("LEFT", BobUI_AbilityTab, "LEFT", 0, 0)
	BobUI_TabTitle:SetPoint("TOP", BobUI_AbilityTab, "TOP", 0, 0)
	BobUI_TabTitle:SetPoint("BOTTOM", BobUI_AbilityTab, "TOP", 0, -1 * (titleHeight + 30))

	BobUI_specButtons:SetHeight(BobUI_Settings["TabIconSize"] + (BobUI_Settings["BorderSize"] * 2) + (BobUI_Settings["SeparatorSize"] * 2) + 20)

	BobUI_specButtons.hSeparatorTop:SetPoint("TOP", BobUI_specButtons, "BOTTOM", 0, BobUI_Settings["SeparatorSize"])
	BobUI_specButtons.hSeparatorBottom:SetPoint("BOTTOM", BobUI_specButtons, "TOP", 0, -1 * BobUI_Settings["SeparatorSize"])

end


function BobUI_AbilityTab_OnShow(self)
	if BobUI_Globals["LOADED"] == false then return end
	if InCombatLockdown() then return end

	updateSpellBookLabel()
	BobUI_AbilityTab:SetScale(BobUI_Settings["Scaling"])

	createSpellButtons()
	updateSpellButtons()

	resizeBackground() 

	if TalentMicroButtonAlert ~= nil then -- needs fixing for SL.
		MicroButtonPulseStop(TalentMicroButton);
		TalentMicroButtonAlert:Hide(); 
	end

	UpdateMicroButtons(); 
	updateBobUI()
end

function BobUI_AbilityTab_OnHide(self)
	if SELECTED_HEART_ESSENCE_SLOT ~= nil then SELECTED_HEART_ESSENCE_SLOT:OnClick() end
	BobUI_specButtons.specButton6:Show()

end


--[[ replace SpellBookFrame_OpenToPageForSlot
function SpellBookFrame_OpenToPageForSlot(slot, reason)

	local alreadyOpen = BobUI_AbilityTab:IsShown();

	if not alreadyOpen then
		ShowUIPanel(SpellBookFrame);
	end

	local _, _, offset = GetSpellTabInfo(BobUI_Globals["VIEWED_SPELL_BOOK"]);
	local relativeSlot = slot - offset
	local button = _G["abilityButton" .. relativeSlot];

	if (slotType == "FLYOUT") then

	else
		if (reason == OPEN_REASON_PENDING_GLYPH) then
			button.AbilityHighlight:Show();
			button.AbilityHighlightAnim:Play();
		elseif (reason == OPEN_REASON_ACTIVATED_GLYPH) then
			button.AbilityHighlightAnim:Stop();
			button.AbilityHighlight:Hide();
			button.GlyphActivate:Show();
			button.GlyphIcon:Show();
			button.GlyphTranslation:Show();
			button.GlyphActivateAnim:Play();
		end
	end
end]]