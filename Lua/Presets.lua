function BobUI_activatePreset(presetName, silent, isHookFunction) -- should not be changed, backwards compatibility. 
    if silent == nil then silent = false end
    if isHookFunction == nil then isHookFunction = false end

    local presetFound = false

    if TalentPresets[BobUI_Globals["CHARACTER"]["classFileName"]][BobUI_Globals["CHARACTER"]["currentSpecializationID"]][presetName] ~= nil then
        presetFound = true

        for k, v in pairs(TalentPresets[BobUI_Globals["CHARACTER"]["classFileName"]][BobUI_Globals["CHARACTER"]["currentSpecializationID"]][presetName]) do
            local tID, tName, _, selected, available, SpellID = GetTalentInfo(k, v[1], GetActiveSpecGroup());

            if tID and not selected then
                LearnTalent(tID)
            end
        end
    end

    if not isHookFunction then -- prevent endless loop between the hook with changing equipment sets and activating presets.
        for k,v in pairs(C_EquipmentSet.GetEquipmentSetIDs()) do
            EquipmentSetName, EquipmentSetTexture = C_EquipmentSet.GetEquipmentSetInfo(v)

            if EquipmentSetName == presetName then
                C_EquipmentSet.UseEquipmentSet(v)
            end
        end
    end

    if HeartPresets[BobUI_Globals["CHARACTER"]["classFileName"]][BobUI_Globals["CHARACTER"]["currentSpecializationID"]][presetName] ~= nil then
        for k, v in pairs(HeartPresets[BobUI_Globals["CHARACTER"]["classFileName"]][BobUI_Globals["CHARACTER"]["currentSpecializationID"]][presetName]) do
            C_AzeriteEssence.ActivateEssence(getEssenceInfoByName(v[2]), v[1])
        end
    end

    if not presetFound and not silent then
        print(BobUI_Globals["ADDON_PREFIX"] .. " - Could not find the specified preset")
    end
end


function getSelectedHeartEssencesTable()
	if showHeartEssences() then
		local selectedEssences = {}

		local j = 1;
		local slot = {};
		local SlottedEssences = {} -- [1] => essenceID, essenceName
		local Milestones = C_AzeriteEssence.GetMilestones();

		for i=1,#Milestones do 
			if Milestones[i].slot ~= nil then 
				slot[j] = Milestones[i].ID; 

				if C_AzeriteEssence.GetMilestoneEssence(Milestones[i].ID) then
					SlottedEssences[j] = C_AzeriteEssence.GetEssenceInfo(C_AzeriteEssence.GetMilestoneEssence(Milestones[i].ID)).name
				end
				j = j + 1; 
			end 
		end

		for k,v in pairs(SlottedEssences) do
			selectedEssences[k] = {slot[k], v}
		end

		return selectedEssences
	else
		return nil 
	end
end

function getSelectedTalentsTable(specID)
	local y1, x1 = 1, 1
	local y2, x2 = 7, 3

	local selectedTalents = {}

	for y=y1, y2 do
		for x=x1, x2 do
			local _, _, _, selected = GetTalentInfo(y, x, GetActiveSpecGroup())
			
			if selected then
				table.insert(selectedTalents, x) -- creates y value and gives it the relevant x value. 
			end
		end
	end
	
	return selectedTalents
end


SELECTED_PRESET_BUTTON = nil
SELECTED_PRESET_DATA = {}
SELECTED_HEART_PRESET_DATA = {}

function getClassNameByFileName(classFileName)
	for i=1, 12 do
		local Name, FileName, ID = GetClassInfo(i)

		if FileName == classFileName then return Name, ID end
	end
end

function updatePresetData()
	if SELECTED_PRESET_BUTTON ~= nil then
		button = SELECTED_PRESET_BUTTON

		local classFileName = button.classFileName
		local className, classID = getClassNameByFileName(classFileName)
		local currentSpecID = button.currentSpecID
		local currentSpecName = button.currentSpecName

		BobTabPage2.talentSetInfo:SetText(CLASS .. ": " .. "\n" .. className .. "\n\n" .. SPECIALIZATION .. ": " .. "\n" .. currentSpecName .. "\n\n" .. TALENTS .. ":");
		for k,v in pairs(SELECTED_PRESET_DATA) do
			local SpellName, SpellID, _, _, _, ActionID = GetSpellInfo(v[2]);

			BobTabPage2.talentSetInfo:SetText(BobTabPage2.talentSetInfo:GetText() .. "\n" .. SpellName);
		end	

		local heartName = C_Item.GetItemNameByID(158075);
	
		BobTabPage2.talentSetInfo:SetText(BobTabPage2.talentSetInfo:GetText() .. "\n\n" .. heartName .. ":");

		for k,v in pairs(SELECTED_HEART_PRESET_DATA) do
			BobTabPage2.talentSetInfo:SetText(BobTabPage2.talentSetInfo:GetText() .. "\n" .. v[2]);
		end
	end
end

function TalentPresets_OnClick(self)
	if self == nil then 
		BobTabPage2.talentSetInfo:SetText()
		return
	end

	if SELECTED_PRESET_BUTTON == NEW_PRESET_BUTTON and self ~= NEW_PRESET_BUTTON then
		FrameNewPresetButton:Hide()
		FrameCurrentClassFrame:SetPoint("TOPLEFT", BobTabPage2ScrollChild, "TOPLEFT", 0, 0);
	end

	SELECTED_PRESET_BUTTON = self

	BobTabPage2NameEditBox:SetText(self:GetText())

	local button = self

	local classFileName = button.classFileName
	local className, classID = getClassNameByFileName(classFileName)
	local currentSpecID = button.currentSpecID
	local currentSpecName = button.currentSpecName


	BobTabPage2.talentSetInfo:SetText(CLASS .. ": " .. "\n" .. className .. "\n\n" .. SPECIALIZATION .. ": " .. "\n" .. currentSpecName .. "\n\n" .. TALENTS .. ":");
	
	SELECTED_PRESET_DATA = {}

	for k,v in pairs(button.talents) do -- needs replacement
		local SpellName, SpellID, _, _, _, ActionID = GetSpellInfo(v[2]); -- should error out atm because v could be nil, if not all talents selected (low lvl)

		SELECTED_PRESET_DATA[k] = {[1] = v[1], [2] = v[2]}

		BobTabPage2.talentSetInfo:SetText(BobTabPage2.talentSetInfo:GetText() .. "\n" .. SpellName);
	end

	if showHeartEssences() then
		SELECTED_HEART_PRESET_DATA = {}

		local heartName = C_Item.GetItemNameByID(158075);

		BobTabPage2.talentSetInfo:SetText(BobTabPage2.talentSetInfo:GetText() .. "\n\n" .. heartName .. ":");

		for k,v in pairs(button.essences) do
			BobTabPage2.talentSetInfo:SetText(BobTabPage2.talentSetInfo:GetText() .. "\n" .. button.essences[k][2]);
		end

		if #button.essences ~= 0 then
			for k,v in pairs(button.essences) do
				SELECTED_HEART_PRESET_DATA[k] = v
			end
		end
	end
	--[[
	local j = 1;
	local slot = {};
	local SlottedEssences = {} -- [1] => essenceID, essenceName
	local Milestones = C_AzeriteEssence.GetMilestones();

	for i=1,#Milestones do 
		if Milestones[i].slot ~= nil and Milestones[i].unlocked == true then 
			slot[j] = Milestones[i].ID; 

			if C_AzeriteEssence.GetMilestoneEssence(Milestones[i].ID) then
				SlottedEssences[j] = C_AzeriteEssence.GetEssenceInfo(C_AzeriteEssence.GetMilestoneEssence(Milestones[i].ID)).name
			end 

			j = j + 1; 
		end 
	end
		button.essences = {}

		for k,v in pairs(SlottedEssences) do
			button.essences[k] = {slot[k], v}
			SELECTED_HEART_PRESET_DATA[k] = {slot[k], v}
		end

	if #button.essences ~= 0 then

		for k,v in pairs(button.essences) do
			SELECTED_HEART_PRESET_DATA[k] = v
		end
	end
	--]]
	
	--[[
	local Essences = C_AzeriteEssence.GetEssences(); 

	for i=1,#Essences do 
		if Essences[i].name == "Vision of Perfection" then 
			C_AzeriteEssences.ActivateEssence(Essences[i].ID, slot[1])
		elseif Essences[i].name == "The Ever-Rising Tide" then 
			C_AzeriteEssences.ActivateEssence(Essences[i].ID, slot[2])
		elseif Essences[i].name == "Memory of Lucid Dreams" then 
			C_AzeriteEssences.ActivateEssence(Essences[i].ID, slot[3])
		elseif Essences[i].name == "Unwavering Ward" then 
			C_AzeriteEssences.ActivateEssence(Essences[i].ID, slot[4])
		end 
	end]]--



end


local buttonsCreated = 0

function createPresetButtons()
	if TalentPresets == nil then TalentPresets = {}; return end
	if HeartPresets == nil then HeartPresets = {}; end

	local button

	local sFrame = BobTabPage2ScrollFrame
	local sChild = BobTabPage2ScrollChild

	if not sFrame.buttons then
		sFrame.buttons = {}
	end

	for i=1,#sFrame.buttons do
		if _G["PresetButton"..i] ~= nil then
			_G["PresetButton"..i]:Hide()
		end
	end

	local className, classFileName, classID = UnitClass("player");
	local currentSpecID = GetSpecialization()
	local cSpecID, currentSpecName = GetSpecializationInfo(currentSpecID);

	if buttonsCreated > 0 then
		for i=1, buttonsCreated do
			sFrame.buttons[i]:Hide()
		end
	end

	buttonsCreated = 0

	local i = 1

	local anchorCurrentSpec = FrameCurrentSpecFrame
	local anchorCurrentClassOtherSpec = FrameCurrentClassOtherSpecFrame
	local anchorOtherClass = FrameOtherClassFrame

	FrameCurrentClassFrame:SetSize(166, 0)
	FrameCurrentSpecFrame:SetSize(166, 0)
	FrameCurrentClassOtherSpecFrame:SetSize(166, 0)
	FrameOtherClassFrame:SetSize(166, 0)

	for k1,v1 in pairs(TalentPresets) do
		for k2, v2 in pairs(v1) do
			for k3, v3 in pairs(v2) do
				local className, classID = getClassNameByFileName(k1)
				local _, currentSpecName, specDescription, texture, role, cFileName, cName = GetSpecializationInfoByID(k2);

				if _G["PresetButton"..i] == nil then
					button = CreateFrame("Button", "PresetButton"..i, sChild, "SecureActionButtonTemplate,BobUI_TalentPresetButtonTemplate");
				else
					button = _G["PresetButton"..i]
				end

				button:SetText(k3)

				button.classFileName = k1
				button.className = className
				button.classID = classID
				button.currentSpecID = k2
				button.currentSpecName = select(2, GetSpecializationInfoByID(k2))
				button.talents = {}
				button.essences = {}
				
				
				local classColorR, classColorG, classColorB = RAID_CLASS_COLORS[k1]:GetRGB()

				for k,v in pairs(v3) do
					local _, tName, _, selected, _, SpellID = GetTalentInfo(k, v[1], GetActiveSpecGroup());
					button.talents[k] = {v[1], v[2]}
				end

				if not HeartPresets[k1] then HeartPresets[k1] = {} end
				if not HeartPresets[k1][k2] then HeartPresets[k1][k2] = {} end
				if not HeartPresets[k1][k2][k3] then 
					HeartPresets[k1][k2][k3] = {}
				else
					
					for k,v in pairs(HeartPresets[k1][k2][k3]) do
						button.essences[k] = {v[1], v[2]}
					end
				end
		
				
				if (k1 == classFileName and k2 == cSpecID) then
					button:SetPoint("TOPLEFT", anchorCurrentSpec, ((anchorCurrentSpec == FrameCurrentSpecFrame) and "TOPLEFT" or "BOTTOMLEFT"), 0, -2);
					FrameCurrentSpecFrame:SetHeight(FrameCurrentSpecFrame:GetHeight() + 22)
					anchorCurrentSpec = button:GetName()
				elseif (k1 == classFileName) then
					button:SetPoint("TOPLEFT", anchorCurrentClassOtherSpec, ((anchorCurrentClassOtherSpec == FrameCurrentClassOtherSpecFrame) and "TOPLEFT" or "BOTTOMLEFT"), 0, -2);
					FrameCurrentClassOtherSpecFrame:SetHeight(FrameCurrentClassOtherSpecFrame:GetHeight() + 22)
					anchorCurrentClassOtherSpec = button:GetName()
				else
					button:SetPoint("TOPLEFT", anchorOtherClass, ((anchorOtherClass == FrameOtherClassFrame) and "TOPLEFT" or "BOTTOMLEFT"), 0, -2);
					FrameOtherClassFrame:SetHeight(FrameOtherClassFrame:GetHeight() + 22)
					anchorOtherClass = button:GetName()
				end
				
				FrameCurrentClassFrame:SetHeight(FrameCurrentSpecFrame:GetHeight() + 2 + FrameCurrentClassOtherSpecFrame:GetHeight())

				button.bg:SetColorTexture(classColorR, classColorG, classColorB, 0.4)
				button:Show();

				button.specIcon:SetTexture(texture)

				tinsert(sFrame.buttons, button)
				
				buttonsCreated = buttonsCreated + 1
				i = i + 1
			end
		end
	end

	sChild:SetSize(166, FrameCurrentClassFrame:GetHeight() + FrameOtherClassFrame:GetHeight())

	TalentPresets_OnClick(SELECTED_PRESET_BUTTON)
end

BobUI_PRESETS_LOADED = false

function TalentPresets_OnLoad()
	if BobUI_PRESETS_LOADED == false then
		local sFrame = BobTabPage2ScrollFrame
		local sChild = BobTabPage2ScrollChild

		sChild:SetParent(sFrame)
		sChild:SetPoint("TOPLEFT", sFrame, "TOPLEFT", 0, 0);

		sFrame:SetScrollChild(sChild)

		local className, classFileName, classID = UnitClass("player");

		sChild:SetHeight(sFrame:GetHeight())
		sChild:SetWidth(sFrame:GetWidth())

		FrameNewPresetButton = CreateFrame("Frame", "FrameNewPresetButton", sChild);
		FrameNewPresetButton:SetSize(166, 20)
		FrameNewPresetButton:SetPoint("TOPLEFT", sChild, "TOPLEFT", 0, 0);
		FrameNewPresetButton:Hide()

		FrameCurrentClassFrame = CreateFrame("Frame", "FrameCurrentClassFrame", sChild);
		FrameCurrentClassFrame:SetSize(166, 0)
		FrameCurrentClassFrame:SetPoint("TOPLEFT", sChild, "TOPLEFT", 0, -4);

		FrameCurrentSpecFrame = CreateFrame("Frame", "FrameCurrentSpecFrame", sChild);
		FrameCurrentSpecFrame:SetSize(166, 0)
		FrameCurrentSpecFrame:SetPoint("TOPLEFT", FrameCurrentClassFrame, "TOPLEFT", 0, 0);

		FrameCurrentClassOtherSpecFrame = CreateFrame("Frame", "FrameCurrentClassOtherSpecFrame", sChild);
		FrameCurrentClassOtherSpecFrame:SetSize(166, 0)
		FrameCurrentClassOtherSpecFrame:SetPoint("TOPLEFT", FrameCurrentSpecFrame, "BOTTOMLEFT", 0, -4);

		FrameOtherClassFrame = CreateFrame("Frame", "FrameOtherClassFrame", sChild);
		FrameOtherClassFrame:SetSize(166, 0)
		FrameOtherClassFrame:SetPoint("TOPLEFT", FrameCurrentClassFrame, "BOTTOMLEFT", 0, -4);

		createPresetButtons()
		BobUI_PRESETS_LOADED = true

		hooksecurefunc("EquipmentManager_EquipSet", function(setID) 
			BobUI_activatePreset(select(1, C_EquipmentSet.GetEquipmentSetInfo(setID)), true, true)
		end)
	end
end

function getEssenceInfoByName(essenceName)
	local essenceList = C_AzeriteEssence.GetEssences()

	for i=1, #essenceList do
		if essenceList[i].name == essenceName then
			return essenceList[i].ID
		end
	end
end

function TalentPresets_OnDoubleClick(self)
	if self == NEW_PRESET_BUTTON then return end
	local specializationID, specializationName = GetSpecializationInfo(GetSpecialization())
	if SELECTED_PRESET_BUTTON.currentSpecID ~= specializationID then return end

	local setName = SELECTED_PRESET_BUTTON:GetText();

	BobUI_activatePreset(setName, true, false)
end



function TalentPresetsControlButtonNew_OnClick()
	-- Add blank button at the top of the list
	local sFrame = BobTabPage2ScrollFrame
	local sChild = BobTabPage2ScrollChild

	local className, classFileName, classID = UnitClass("player");
	local currentSpecID = GetSpecialization();
	local cSpecID, currentSpecName = GetSpecializationInfo(currentSpecID);
	local talents = getSelectedTalentsTable(currentSpecID);
	local classColorR, classColorG, classColorB = RAID_CLASS_COLORS[classFileName]:GetRGB()
	local button = nil

	if not sFrame.buttons then
		sFrame.buttons = {}
	end

	if NEW_PRESET_BUTTON == nil then

		button = CreateFrame("Button", "NEW_PRESET_BUTTON", FrameNewPresetButton, "SecureActionButtonTemplate,BobUI_TalentPresetButtonTemplate");
		button:SetText(PAPERDOLL_NEWEQUIPMENTSET)
		button:SetPoint("TOPLEFT", FrameNewPresetButton, "TOPLEFT", 0, 0);
	else
		button = NEW_PRESET_BUTTON
	end	

	button.classFileName = classFileName
	button.className = className
	button.currentSpecID = cSpecID
	button.currentSpecName = currentSpecName
	button.talents = {}

	for k,v in pairs(talents) do
		local _, tName, _, selected, _, SpellID = GetTalentInfo(k, v, GetActiveSpecGroup());
		button.talents[k] = {v, SpellID}
	end
	if showHeartEssences() then
		local essences = getSelectedHeartEssencesTable()

		button.essences = {}

		for k,v in pairs(essences) do
			button.essences[k] = {v[1], v[2]}
		end
	end

	button.bg:SetColorTexture(classColorR, classColorG, classColorB, 0.4)
	tinsert(sFrame.buttons, button)

	if FrameNewPresetButton:IsShown() then
		FrameNewPresetButton:Hide()
		FrameCurrentClassFrame:SetPoint("TOPLEFT", BobTabPage2ScrollChild, "TOPLEFT", 0, 0);
		
		SELECTED_PRESET_BUTTON = nil
		createPresetButtons()
	else
		FrameNewPresetButton:Show()
		FrameCurrentClassFrame:SetPoint("TOPLEFT", FrameNewPresetButton, "BOTTOMLEFT", 0, -4);

		NEW_PRESET_BUTTON:Show()
		NEW_PRESET_BUTTON:Click()
	end
end

function TalentPresetsControlButtonSave_OnClick()
	if SELECTED_PRESET_BUTTON == nil then return end

	local className, classFileName, classID = UnitClass("player");
	local currentSpecID = GetSpecialization();
	local cSpecID, currentSpecName = GetSpecializationInfo(currentSpecID);

	if not TalentPresets then
		TalentPresets = {}
	end

	local oldPresetName = SELECTED_PRESET_BUTTON:GetText()
	local newPresetName = BobTabPage2NameEditBox:GetText()

	local sFrame = BobTabPage2ScrollFrame
	local sChild = BobTabPage2ScrollChild

	-- add to relevant category and highlight it

	if SELECTED_PRESET_BUTTON == NEW_PRESET_BUTTON then
		FrameNewPresetButton:Hide()
		FrameCurrentClassFrame:SetPoint("TOPLEFT", sChild, "TOPLEFT", 0, 0);
	end
	
	if not TalentPresets[classFileName] then TalentPresets[classFileName] = {} end
	if not TalentPresets[classFileName][cSpecID] then TalentPresets[classFileName][cSpecID] = {} end



	TalentPresets[classFileName][cSpecID][oldPresetName] = nil
	TalentPresets[classFileName][cSpecID][newPresetName] = {}
	

	for k,v in pairs(SELECTED_PRESET_DATA) do
		tinsert(TalentPresets[classFileName][cSpecID][newPresetName], v)
	end

	if showHeartEssences() then
		if not HeartPresets then
			HeartPresets = {}
		end

		if not HeartPresets[classFileName] then HeartPresets[classFileName] = {} end
		if not HeartPresets[classFileName][cSpecID] then HeartPresets[classFileName][cSpecID] = {} end

		HeartPresets[classFileName][cSpecID][oldPresetName] = nil
		HeartPresets[classFileName][cSpecID][newPresetName] = {}

		for k,v in pairs(SELECTED_HEART_PRESET_DATA) do
			tinsert(HeartPresets[classFileName][cSpecID][newPresetName], v)
		end

		SELECTED_HEART_PRESET_DATA = nil
	end
	

	SELECTED_PRESET_DATA = nil
	createPresetButtons()
end

function TalentPresetsControlButtonDelete_OnClick()
	if SELECTED_PRESET_BUTTON ~= nil and SELECTED_PRESET_BUTTON ~= NEW_PRESET_BUTTON then
		TalentPresets[SELECTED_PRESET_BUTTON.classFileName][SELECTED_PRESET_BUTTON.currentSpecID][SELECTED_PRESET_BUTTON:GetText()] = nil
		HeartPresets[SELECTED_PRESET_BUTTON.classFileName][SELECTED_PRESET_BUTTON.currentSpecID][SELECTED_PRESET_BUTTON:GetText()] = nil

	else
		if SELECTED_PRESET_BUTTON == NEW_PRESET_BUTTON then
			FrameNewPresetButton:Hide()
			FrameCurrentClassFrame:SetPoint("TOPLEFT", BobTabPage2ScrollChild, "TOPLEFT", 0, 0);
		end
	end

	SELECTED_PRESET_BUTTON = nil
	createPresetButtons()
end