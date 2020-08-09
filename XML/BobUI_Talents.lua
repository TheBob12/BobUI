-- BobUI_Talents.lua will eventually be removed and split up into relevant files.
MAX_TALENT_TIERS = 7;
NUM_TALENT_COLUMNS = 3;

DEFAULT_TALENT_SPEC = "spec1";


local min = min;
local max = max;
local huge = math.huge;
local rshift = bit.rshift;

function BobUI_TalentFrame_Update(TalentFrame, talentUnit)
	if BobUI_Globals["LOADED"] == false then return end
	if ( not TalentFrame ) then
		return;
	end
	
	local disable;
	if ( TalentFrame.inspect ) then
		
		disable = false;
	else
		disable = ( TalentFrame.talentGroup ~= GetActiveSpecGroup(TalentFrame.inspect) );
	end
	if(TalentFrame.bg ~= nil) then
		TalentFrame.bg:SetDesaturated(disable);
	end
	
	local TalentFrameHeight = ((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2)) * 7) + BobUI_Settings["FontSizeBody"] + 30 + 2

	TalentFrame:GetParent():SetSize(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2)) * 4) + 10 + 20 + (2 * BobUI_Settings["SeparatorSize"]), TalentFrameHeight)
	TalentFrame:SetSize(TalentFrame:GetParent():GetSize())
	
	if BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrameTalentList:IsShown() then
		TalentFrame.BobUI_PvpTalentFrame:SetSize(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2) + (BobUI_Settings["SpellIconSize"] * 2 + 2)) + 10 + 20) + 10 + BobUI_Settings["SeparatorSize"], TalentFrameHeight)
	else
		TalentFrame.BobUI_PvpTalentFrame:SetSize(TalentFrame.BobUI_PvpTalentFrame.titleFrame.category:GetWidth() + 20 + BobUI_Settings["SeparatorSize"], TalentFrameHeight)
	end

	if TalentFrame.heartEssenceFrame.essenceList:IsShown() then
		TalentFrame.heartEssenceFrame:SetSize(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2) + (((BobUI_Settings["BorderSize"] * 2) + BobUI_Settings["SpellIconSize"]) * 3 + 4)) + 10 + 20), TalentFrameHeight)
	else
		TalentFrame.heartEssenceFrame:SetSize(TalentFrame.heartEssenceFrame.titleFrame.category:GetWidth() + 10, TalentFrameHeight)
	end
	
	
	TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:SetSize(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2))), ((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2))))
	TalentFrame.BobUI_PvpTalentFrame.TalentSlot1:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())
	TalentFrame.BobUI_PvpTalentFrame.TalentSlot2:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())
	TalentFrame.BobUI_PvpTalentFrame.TalentSlot3:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())

	TalentFrame.heartEssenceFrame.HeartSlot1:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())
	TalentFrame.heartEssenceFrame.HeartSlot2:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())
	TalentFrame.heartEssenceFrame.HeartSlot3:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())
	TalentFrame.heartEssenceFrame.HeartSlot4:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())


	TalentFrame.BobUI_PvpTalentFrame.InvisibleWarmodeButton:SetSize(TalentFrame.BobUI_PvpTalentFrame.TrinketSlot:GetSize())

	TalentFrame.borderLeft:SetPoint("RIGHT", TalentFrame, "LEFT", BobUI_Settings["SeparatorSize"], 0)
	TalentFrame.borderRight:SetPoint("LEFT", TalentFrame, "RIGHT", -1 * BobUI_Settings["SeparatorSize"], 0)
	TalentFrame.BobUI_PvpTalentFrame.borderRight:SetPoint("LEFT", TalentFrame.BobUI_PvpTalentFrame, "RIGHT", -1 * BobUI_Settings["SeparatorSize"], 0)

	for tier=1, MAX_TALENT_TIERS do
		local talentRow = TalentFrame["tier"..tier];
		local rowAvailable = true;

		talentRow:SetSize(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2)) * 4) + 10, BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2))
		talentRow.level:SetSize(BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2), BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2))

		local TextColors = BobUI_Settings["TextColor"]
		talentRow.level:SetTextColor(TextColors["r"], TextColors["g"], TextColors["b"], TextColors["a"]);

		local tierAvailable, selectedTalent = GetTalentTierInfo(tier, TalentFrame.talentGroup, TalentFrame.inspect, talentUnit);
		
		if (TalentFrame.inspect or not TalentFrame.talentInfo[tier] or
			(selectedTalent ~= 0 and TalentFrame.talentInfo[tier] == selectedTalent)) then
			
			if (not TalentFrame.inspect and selectedTalent ~= 0) then
				TalentFrame.talentInfo[tier] = nil;
			end
			
			local restartGlow = false;
			for column=1, NUM_TALENT_COLUMNS do
				
				local talentID, name, iconTexture, selected, available, _, _, _, _, _, grantedByAura = GetTalentInfo(tier, column, TalentFrame.talentGroup, TalentFrame.inspect, talentUnit);
				local button = talentRow["talent"..column];
				button.tier = tier;
				button.column = column;
				
				button.icon:SetSize(BobUI_Settings["SpellIconSize"], BobUI_Settings["SpellIconSize"])
				button:SetSize(BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2), BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2))

				if (button and name) then
					button:SetID(talentID);

					button.icon:SetTexture(iconTexture);

					if(button.name ~= nil) then
						button.name:SetText(name);
					end

					if(button.knownSelection ~= nil) then
						if ( grantedByAura ) then
							button.knownSelection:Show();
							
							button.knownSelection:SetDesaturated(disable);

						elseif ( selected ) then
							button.bg:SetColorTexture(GetBorderColor("BorderColorActive"))
						else
							button.bg:SetColorTexture(0.1, 0.1, 0.1, 1)
							button.knownSelection:Hide();
						end
					end
					button.shouldGlow = (available and not selected) and talentUnit == "player";
					if ( button.grantedByAura ~= grantedByAura ) then
						button.grantedByAura = grantedByAura;
						restartGlow = true;
					end
					
					if( TalentFrame.inspect ) then
						SetDesaturation(button.icon, not (selected or grantedByAura));
						button.border:SetShown(selected or grantedByAura);
						if ( grantedByAura ) then
							local color = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_LEGENDARY];
							button.border:SetVertexColor(color.r, color.g, color.b);
						else
							button.border:SetVertexColor(1, 1, 1);
						end
					else
						button.disabled = (not tierAvailable or disable);
						SetDesaturation(button.icon, (button.disabled or (selectedTalent ~= 0 and not selected)) and not grantedByAura);
						button.Cover:SetShown(button.disabled);
						button.highlight:SetAlpha((selected or not tierAvailable) and 0 or 1);
					end
					
					button:Show();
				elseif (button) then
					button:Hide();
				end
			end
			BobUI_TalentFrame_UpdateRowGlow(talentRow, restartGlow);
			
		end
	end
	if(TalentFrame.unspentText ~= nil) then
		local numUnspentTalents = GetNumUnspentTalents();
		if ( not disable and numUnspentTalents > 0 ) then
			TalentFrame.unspentText:SetFormattedText(PLAYER_UNSPENT_TALENT_POINTS, numUnspentTalents);
		else
			TalentFrame.unspentText:SetText("");
		end
	end
end

function BobUI_TalentFrame_UpdateRowGlow(talentRow, restartGlow)
	if ( talentRow.GlowFrame ) then
		local somethingGlowing = false;
		for i, button in ipairs(talentRow.talents) do
			if ( button.shouldGlow and not button.grantedByAura ) then
				somethingGlowing = true;
				if ( restartGlow ) then
					button.GlowFrame:Hide();
				end
				button.GlowFrame:Show();
			else
				button.GlowFrame:Hide();
			end
		end
		if ( somethingGlowing ) then
			if ( restartGlow ) then
				talentRow.GlowFrame:Hide();
			end
			talentRow.GlowFrame:Show();
		else
			talentRow.GlowFrame:Hide();
		end
	end
end


BobUI_PvpTalentSlotMixin = {};

local SLOT_NEW_STATE_OFF = 1;
local SLOT_NEW_STATE_SHOW_IF_ENABLED = 2;
local SLOT_NEW_STATE_ACKNOWLEDGED = 3;

function BobUI_PvpTalentSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self.slotNewState = SLOT_NEW_STATE_OFF;

	SetClampedTextureRotation(self.Arrow, 90);
end

function BobUI_PvpTalentSlotMixin:OnShow()
	self:RegisterEvent("PLAYER_PVP_TALENT_UPDATE");
end

function BobUI_PvpTalentSlotMixin:OnHide()
	self:UnregisterEvent("PLAYER_PVP_TALENT_UPDATE");
end

function BobUI_PvpTalentSlotMixin:OnEvent(event)
	if (event == "PLAYER_PVP_TALENT_UPDATE") then
		self.predictedSetting:Clear();
		self:Update();
	end
end

function BobUI_PvpTalentSlotMixin:GetSelectedTalent()
	return self.predictedSetting:Get();
end

function BobUI_PvpTalentSlotMixin:SetSelectedTalent(talentID)
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID and selectedTalentID == talentID) then
		return;
	end
	self.predictedSetting:Set(talentID);
	self:Update();
end

function BobUI_PvpTalentSlotMixin:SetUp(slotIndex)
	self.slotIndex = slotIndex;
	self.predictedSetting = CreatePredictedSetting(
		{
			["setFunction"] = function(value)
				return LearnPvpTalent(value, slotIndex);
			end, 
			["getFunction"] = function()
				if not self:IsPendingTalentRemoval() then
					local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex);
					return slotInfo and slotInfo.selectedTalentID;
				end
			end, 
		}
	);
	
	self:Update();
end

function BobUI_PvpTalentSlotMixin:SetPendingTalentRemoval(isPending)
	self.isPendingRemoval = isPending;
end

function BobUI_PvpTalentSlotMixin:IsPendingTalentRemoval()
	return self.isPendingRemoval or false;
end

function BobUI_PvpTalentSlotMixin:Update()
	if BobUI_Globals["LOADED"] == false then return end
	if (not self.slotIndex) then
		error("Slot must be setup with a slot index first.");
	end

	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
	self.Texture:Show();
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID) then
		local _, name, texture = GetPvpTalentInfoByID(selectedTalentID);
		self.Texture:SetTexture(texture);

	else
		self.Texture:SetAtlas("pvptalents-talentborder-empty");
	end

	local showNewLabel = false;
	if (slotInfo and slotInfo.enabled) then
		self.Border:SetAtlas("pvptalents-talentborder");
		self:Enable();
		showNewLabel = self.slotNewState == SLOT_NEW_STATE_SHOW_IF_ENABLED;
	else
		self.Border:SetAtlas("pvptalents-talentborder-locked");
		self:Disable();
		self.Texture:Hide();
		if slotInfo and not slotInfo.enabled and self.slotNewState == SLOT_NEW_STATE_OFF then
			if UnitLevel("player") < slotInfo.level then
				self.slotNewState = SLOT_NEW_STATE_SHOW_IF_ENABLED;
			end
		end
	end
	self.New:SetShown(showNewLabel);
	self.NewGlow:SetShown(showNewLabel);
end

function BobUI_PvpTalentSlotMixin:OnEnter()
	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
	if not slotInfo then
		return;
	end

	if (self.slotNewState == SLOT_NEW_STATE_SHOW_IF_ENABLED and slotInfo.enabled) then
		self.slotNewState = SLOT_NEW_STATE_ACKNOWLEDGED;
		self.New:Hide();
		self.NewGlow:Hide();
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local selectedTalentID = self:GetSelectedTalent();
	if (selectedTalentID) then
		GameTooltip:SetPvpTalent(selectedTalentID, false, GetActiveSpecGroup(true), self.slotIndex);
	else
		GameTooltip:SetText(PVP_TALENT_SLOT);
		if (not slotInfo.enabled) then
			GameTooltip:AddLine(PVP_TALENT_SLOT_LOCKED:format(C_SpecializationInfo.GetPvpTalentSlotUnlockLevel(self.slotIndex)), RED_FONT_COLOR:GetRGB());
		else
			GameTooltip:AddLine(PVP_TALENT_SLOT_EMPTY, GREEN_FONT_COLOR:GetRGB());
		end
	end

	GameTooltip:Show();
end

function BobUI_PvpTalentSlotMixin:OnClick()
	local selectedTalentID = self:GetSelectedTalent();
	if (IsModifiedClick("CHATLINK") and selectedTalentID) then
		local _, name = GetPvpTalentInfoByID(selectedTalentID);
		local link = GetPvpTalentLink(selectedTalentID);
		HandleGeneralTalentFrameChatLink(self, name, link);
		return;
	end
	
	self:GetParent():SelectSlot(self);

	local TalentFrame = BobUI_PlayerTalentFrameTalents
	local TalentFrameHeight = ((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2)) * 7) + BobUI_Settings["FontSizeBody"] + 30 + 2
	
	local TalentFrameWidth = max(((BobUI_Settings["SpellIconSize"] + (BobUI_Settings["BorderSize"] * 2) + (BobUI_Settings["SpellIconSize"] * 2 + 2)) + 10 + 20) + 10 + BobUI_Settings["SeparatorSize"], TalentFrame.BobUI_PvpTalentFrame.titleFrame.category:GetWidth() + 20)

	if BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrameTalentList:IsShown() then
		TalentFrame.BobUI_PvpTalentFrame:SetSize(TalentFrameWidth, TalentFrameHeight)
	else
		TalentFrame.BobUI_PvpTalentFrame:SetSize(TalentFrame.BobUI_PvpTalentFrame.titleFrame.category:GetWidth() + 20 + BobUI_Settings["SeparatorSize"], TalentFrameHeight)
	end

	resizeBackground()
end

function BobUI_PvpTalentSlotMixin:OnDragStart()
	if (not self.isInspect) then
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(self.slotIndex);
		if slotInfo and slotInfo.selectedTalentID then
			local predictedTalentID = self:GetSelectedTalent();
			if (not predictedTalentID or predictedTalentID == slotInfo.selectedTalentID) then
				PickupPvpTalent(slotInfo.selectedTalentID);
			end
		end
	end
end







local specs = {
	["spec1"] = {
		name = SPECIALIZATION_PRIMARY,
		nameActive = TALENT_SPEC_PRIMARY_ACTIVE,
		specName = SPECIALIZATION_PRIMARY,
		specNameActive = SPECIALIZATION_PRIMARY_ACTIVE,
		talentGroup = 1,
		tooltip = SPECIALIZATION_PRIMARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
	},
	["spec2"] = {
		name = SPECIALIZATION_SECONDARY,
		nameActive = TALENT_SPEC_SECONDARY_ACTIVE,
		specName = SPECIALIZATION_SECONDARY,
		specNameActive = SPECIALIZATION_SECONDARY_ACTIVE,
		talentGroup = 2,
		tooltip = SPECIALIZATION_SECONDARY,
		defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
	},
};

local selectedSpec = nil;
local activeSpec = nil;

function BobUI_PlayerTalentFrame_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("PET_SPECIALIZATION_CHANGED");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("PLAYER_LEARN_TALENT_FAILED");
	
	self.inspect = false;
	self.talentGroup = 1;
	self.selectedPlayerSpec = DEFAULT_TALENT_SPEC;

	local _, playerClass = UnitClass("player");

	BobUI_PlayerTalentFrame_UpdateActiveSpec(GetActiveSpecGroup(false));
	selectedSpec = activeSpec;

end

function BobUI_PlayerTalentFrame_OnShow(self)
	BobUI_PlayerTalentFrame_Refresh();
end

function BobUI_PlayerTalentFrame_OnHide()
	HelpPlate_Hide();

	StaticPopup_Hide("CONFIRM_LEARN_SPEC");
end

function BobUI_PlayerTalentFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if (self:IsShown()) then
		if ( event == "ADDON_LOADED" ) then
			BobUI_PlayerTalentFrame_ClearTalentSelections();
		elseif ( event == "PET_SPECIALIZATION_CHANGED" or
				 event == "PLAYER_TALENT_UPDATE" ) then
			BobUI_PlayerTalentFrame_Refresh();
		elseif ( event == "UNIT_LEVEL") then
			if ( selectedSpec ) then
				local arg1 = ...;
				if (arg1 == "player") then
					BobUI_PlayerTalentFrame_Update();
				end
			end
		elseif (event == "LEARNED_SPELL_IN_TAB") then
			
		end
	end
	if (event == "PLAYER_LEARN_TALENT_FAILED") then
		local talentFrame = BobUI_PlayerTalentFrameTalents;

		local talentIds = GetFailedTalentIDs();
		for i = 1, #talentIds do
			local row, column = select(8, GetTalentInfoByID(talentIds[i], BobUI_PlayerTalentFrame.talentGroup));
			if (talentFrame.talentInfo[row] == column) then
				talentFrame.talentInfo[row] = nil;
			end
		end
		BobUI_TalentFrame_Update(talentFrame, "player");
		ClearFailedTalentIDs();
	end
end


function BobUI_PlayerTalentFrame_Refresh()
	selectedSpec = BobUI_PlayerTalentFrame.selectedPlayerSpec;
	BobUI_PlayerTalentFrame.talentGroup = specs[selectedSpec].talentGroup;
	local name, count, texture, spellID;

	BobUI_PlayerTalentFrameTalents.talentGroup = BobUI_PlayerTalentFrame.talentGroup;
	BobUI_TalentFrame_Update(BobUI_PlayerTalentFrameTalents, "player");
	BobUI_PlayerTalentFrameTalents:Show();
	

	BobUI_PlayerTalentFrame_Update();
end

function BobUI_PlayerTalentFrame_Update(playerLevel)
	local activeTalentGroup, numTalentGroups = GetActiveSpecGroup(false), GetNumSpecGroups(false);
	BobUI_PlayerTalentFrame.primaryTree = GetSpecialization(BobUI_PlayerTalentFrame.inspect, false, BobUI_PlayerTalentFrame.talentGroup);

	BobUI_PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup);

	return true;
end

function BobUI_PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup)
	activeSpec = DEFAULT_TALENT_SPEC;
	for index, spec in next, specs do
		if (spec.talentGroup == activeTalentGroup ) then
			activeSpec = index;
			break;
		end
	end
end

function BobUI_PlayerTalentFrame_SelectTalent(tier, id)
	local talentRow = BobUI_PlayerTalentFrameTalents["tier"..tier];
	if ( talentRow.selectionId == id ) then
		talentRow.selectionId = nil;
	else
		talentRow.selectionId = id;
	end
	BobUI_TalentFrame_Update(BobUI_PlayerTalentFrameTalents, "player");
end

function BobUI_PlayerTalentFrame_ClearTalentSelections()
	for tier = 1, MAX_TALENT_TIERS do
		local talentRow = BobUI_PlayerTalentFrameTalents["tier"..tier];
		talentRow.selectionId = nil;
	end
end

function BobUI_PlayerTalentFrame_GetTalentSelections()
	local talents = { };
	for tier = 1, MAX_TALENT_TIERS do
		local talentRow = BobUI_PlayerTalentFrameTalents["tier"..tier];
		if ( talentRow.selectionId ) then
			tinsert(talents, talentRow.selectionId);
		end
	end
	return unpack(talents);
end

function BobUI_PlayerTalentFrameRow_OnEnter(self)
	if ( self.GlowFrame ) then
		self.GlowFrame:Hide();
		for i, button in ipairs(self.talents) do
			button.GlowFrame:Hide();
		end
	end
end

function BobUI_PlayerTalentFrameRow_OnLeave(self)
	BobUI_TalentFrame_UpdateRowGlow(self);
end

function HandleGeneralTalentFrameChatLink(self, talentName, talentLink)
	if ( MacroFrameText and MacroFrameText:HasFocus() ) then
		local spellName = GetSpellInfo(talentName);
		if ( spellName and not IsPassiveSpell(spellName) ) then
			local subSpellName = GetSpellSubtext(talentName);
			if ( subSpellName ) then
				if ( subSpellName ~= "" ) then
					ChatEdit_InsertLink(spellName.."("..subSpellName..")");
				else
					ChatEdit_InsertLink(spellName);
				end
			end
		end
	elseif ( talentLink ) then
		ChatEdit_InsertLink(talentLink);
	end
end

local function HandleTalentFrameChatLink(self)
	local _, name = GetTalentInfoByID(self:GetID(), specs[selectedSpec].talentGroup, false);
	local link = GetTalentLink(self:GetID());
	HandleGeneralTalentFrameChatLink(self, name, link);
end

function BobUI_PlayerTalentFrameTalent_OnClick(self, button)
	if ( selectedSpec and (activeSpec == selectedSpec)) then
        local talentID = self:GetID()
		local _, _, _, _, available, _, _, _, _, known = GetTalentInfoByID(talentID, specs[selectedSpec].talentGroup, true);
		if ( available and not known and button == "LeftButton") then
            return LearnTalent(talentID);
		end
	end
	return false;
end

function BobUI_PlayerTalentFrameTalent_OnDrag(self, button)
	PickupTalent(self:GetID());
end

function BobUI_PlayerTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(self:GetID(),
		BobUI_PlayerTalentFrame.inspect, BobUI_PlayerTalentFrame.talentGroup);
	end
end

function BobUI_PlayerTalentFrameTalent_OnEnter(self)
	BobUI_PlayerTalentFrameRow_OnEnter(self:GetParent());
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetTalent(self:GetID(), BobUI_PlayerTalentFrame.inspect, BobUI_PlayerTalentFrame.talentGroup);
	self.UpdateTooltip = BobUI_PlayerTalentFrameTalent_OnEnter;
end

function BobUI_PlayerTalentFrameTalent_OnLeave(self)
	BobUI_PlayerTalentFrameRow_OnLeave(self:GetParent());
	GameTooltip_Hide();
end

function BobUI_PlayerTalentFrameTalents_OnLoad()
	local _, class = UnitClass("player");
	local talentLevels = CLASS_TALENT_LEVELS[class] or CLASS_TALENT_LEVELS["DEFAULT"];
	for i=1, MAX_TALENT_TIERS do
		BobUI_PlayerTalentFrameTalents["tier"..i].level:SetText(talentLevels[i]);
	end

	BobUI_PlayerTalentFrameTalents.talentInfo = {};
end

function BobUI_PlayerTalentFrameTalents_OnShow(self)
	local playerLevel = UnitLevel("player");
	if ( playerLevel >= SHOW_TALENT_LEVEL and AreTalentsLocked() ) then
		BobUI_PlayerTalentFrameLockInfo:Show();
		BobUI_PlayerTalentFrameLockInfo.Title:SetText(TALENTS_FRAME_TALENT_LOCK_TITLE);
		BobUI_PlayerTalentFrameLockInfo.Text:SetText(TALENTS_FRAME_TALENT_LOCK_DESC)
	else
		BobUI_PlayerTalentFrameLockInfo:Hide();
	end
end

function BobUI_PlayerTalentFrameTalents_OnHide(self)
	BobUI_PlayerTalentFrameLockInfo:Hide();
end

function BobUI_PlayerTalentButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
end

function BobUI_PlayerTalentButton_OnClick(self, button)
	if (IsModifiedClick("CHATLINK")) then
		HandleTalentFrameChatLink(self);
		return;
	end

	local talentRow = self:GetParent();
	local talentsFrame = talentRow:GetParent();
	if (talentsFrame.talentInfo[self.tier]) then
		UIErrorsFrame:AddMessage(TALENT_CLICK_TOO_FAST, 1.0, 0.1, 0.1, 1.0);
		return;
	elseif (not self.disabled) then
		if (UnitAffectingCombat("player")) then
			UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0);
			return;
		end

		local learn = BobUI_PlayerTalentFrameTalent_OnClick(self, button);

		if (learn) then
			talentsFrame.talentInfo[self.tier] = self.column;

			self.icon:SetDesaturated(false);

			for i = 1, #talentRow.talents do
				if (i ~= self.column) then
					local oldTalentButton = talentRow.talents[i];
					oldTalentButton.icon:SetDesaturated(true);
				end
			end
			if(talentRow.level ~= nil) then
				local TextColors = BobUI_Settings["TextColor"]
			
				talentRow.level:SetTextColor(TextColors["r"], TextColors["g"], TextColors["b"], TextColors["a"]);
			end
		end
	end
end

BobUI_PvpTalentFrameMixin = {};

local BobUI_PvpTalentFrameEvents = {
	"PLAYER_PVP_TALENT_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_SPECIALIZATION_CHANGED",
	"WAR_MODE_STATUS_UPDATE",
	"UI_MODEL_SCENE_INFO_UPDATED",
};

TALENT_WAR_MODE_BUTTON = nil;
local round = function (num) return math.floor(num + .5); end

function BobUI_CreateHybridScrollFrameButtons(self, buttonTemplate, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
	local scrollChild = self.scrollChild;
	local button, buttonHeight, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	initialPoint = initialPoint or "TOPLEFT";
	initialRelative = initialRelative or "TOPLEFT";
	point = point or "TOPLEFT";
	relativePoint = relativePoint or "BOTTOMLEFT";
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;

	if ( self.buttons ) then
		buttonHeight = BobUI_Settings["SpellIconSize"];
	else
		button = CreateFrame("BUTTON", buttonName and (buttonName .. 1) or nil, scrollChild, buttonTemplate);
		buttonHeight = BobUI_Settings["SpellIconSize"];
		button:SetPoint(initialPoint, scrollChild, initialRelative, initialOffsetX, initialOffsetY);
		self.buttons = {}
		tinsert(self.buttons, button);
	end

	self.buttonHeight = round(buttonHeight) - offsetY;

	local numButtons = math.ceil((self:GetHeight() * 2) / buttonHeight) + 1;

	for i = #self.buttons + 1, numButtons do
		button = CreateFrame("BUTTON", buttonName and (buttonName .. i) or nil, scrollChild, buttonTemplate);
		button:SetPoint(point, self.buttons[i-1], relativePoint, offsetX, offsetY);
		tinsert(self.buttons, button);
	end

	scrollChild:SetWidth(buttonHeight * 2 + 2)
	scrollChild:SetHeight(numButtons * buttonHeight);

	self:SetVerticalScroll(0);
	self:UpdateScrollChildRect();

end

function BobUI_PvpTalentFrame_OnLoad()
	TALENT_WAR_MODE_BUTTON = BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.InvisibleWarmodeButton;

	BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame:RegisterEvent("PLAYER_LEVEL_CHANGED");
	for i, slot in ipairs(BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.Slots) do
		slot:SetUp(i);
	end

	BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.InvisibleWarmodeButton:SetUp();

	BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.TalentList.ScrollFrame.update = function() BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.TalentList:Update() end;
	BobUI_CreateHybridScrollFrameButtons(BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFrame.TalentList.ScrollFrame, "BobUI_PvpTalentButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM");
end

function BobUI_PvpTalentFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_PVP_TALENT_UPDATE" then
		self:ClearPendingRemoval();
		self:Update();
	elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "WAR_MODE_STATUS_UPDATE" then
		self:Update();
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local forceUpdate = true;
		self:UpdateModelScenes(forceUpdate);
	elseif event == "PLAYER_LEVEL_CHANGED" then
		self:Update();
	end
end

function BobUI_PvpTalentFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, BobUI_PvpTalentFrameEvents);
	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PVP_TALENTS_FIRST_UNLOCK)) then
		local helpTipInfo = {
			text = PVP_TALENT_FIRST_TALENT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_PVP_TALENTS_FIRST_UNLOCK,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -2,
		};
		HelpTip:Show(self.TrinketSlot, helpTipInfo);
	end
	self:Update();

	for i, slot in ipairs(self.Slots) do
		slot.Arrow:SetSize(20, 20)
		slot.Arrow:SetPoint("LEFT", slot.Arrow:GetParent(), "RIGHT", 0, 0);

	end

end

function BobUI_PvpTalentFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, BobUI_PvpTalentFrameEvents);

	self:UnselectSlot();
end

function BobUI_PvpTalentFrameMixin:UpdateModelScene(scene, sceneID, fileID, forceUpdate)
	if (not scene) then
		return;
	end

	scene:Show();
	scene:SetFromModelSceneID(sceneID, forceUpdate);
	local effect = scene:GetActorByTag("effect");
	if (effect) then
		effect:SetModelByFileID(fileID);
	end
end

function BobUI_PvpTalentFrameMixin:ClearPendingRemoval()
	for slotIndex = 1, #self.Slots do
		local slot = self.Slots[slotIndex];
		slot:SetPendingTalentRemoval(false);
		slot:Update();
	end
end

function BobUI_PvpTalentFrameMixin:Update()
	if (not C_PvP.IsWarModeFeatureEnabled() or UnitLevel("player") < SHOW_PVP_TALENT_LEVEL) then
		self:Hide();
		self.currentWarModeState = "hidden";
		return;
	else
		self.currentWarModeState = "shown";
	end

	for _, slot in pairs(self.Slots) do
		slot:Update();
	end

	self.TalentList:Update();

	self:UpdateModelScenes();

	self.InvisibleWarmodeButton:Update();
	
end

function BobUI_PvpTalentFrameMixin:UpdateModelScenes(forceUpdate)
	if (self.InvisibleWarmodeButton:GetWarModeDesired() == self.lastKnownDesiredState) then
		return;
	end

	self.lastKnownDesiredState = self.InvisibleWarmodeButton:GetWarModeDesired();
end

function BobUI_PvpTalentFrameMixin:SelectSlot(slot)
	if (self.selectedSlotIndex) then
		local sameSelected = self.selectedSlotIndex == slot.slotIndex;
		self:UnselectSlot();
		if (sameSelected) then
			return;
		end
	end
	
	self.selectedSlotIndex = slot.slotIndex;
	slot.Arrow:Show();
	HybridScrollFrame_SetOffset(self.TalentList.ScrollFrame, 0);
	self.TalentList:Update();
	self.TalentList:Show();
end

function BobUI_PvpTalentFrameMixin:UnselectSlot()
	if (not self.selectedSlotIndex) then
		return;
	end

	local slot = self.Slots[self.selectedSlotIndex];

	slot.Arrow:Hide();
	self.TalentList:Hide();
	self.selectedSlotIndex = nil;
	
end

function BobUI_PvpTalentFrameMixin:SelectTalentForSlot(talentID, slotIndex)
	local slot = self.Slots[slotIndex];

	if (not slot or slot:GetSelectedTalent() == talentID) then
		return;
	end

	for existingSlotIndex = 1, #self.Slots do
		local existingSlot = self.Slots[existingSlotIndex];
		if existingSlot:GetSelectedTalent() == talentID then
			existingSlot:SetPendingTalentRemoval(true);
			break;
		end
	end

	slot:SetSelectedTalent(talentID);
	self:UnselectSlot();
end

PvpTalentButtonMixin = {};

function PvpTalentButtonMixin:SetPvpTalent(talentID)
	self.talentID = talentID;
end

function PvpTalentButtonMixin:Update(selectedHere, selectedOther)
	local talentID, name, icon, selected, available, spellID, unlocked = GetPvpTalentInfoByID(self.talentID);

	self.New:Hide();
	self.NewGlow:Hide();

	if (not unlocked) then
		self.Icon:SetDesaturated(true);
		self.Selected:Hide();
		self.disallowNormalClicks = true;
	else
		if (C_SpecializationInfo.IsPvpTalentLocked(self.talentID)) then
			self.New:Show();
			self.NewGlow:Show();
		end
		self.Icon:SetDesaturated(false);
		self.Selected:SetShown(selectedHere);
		self.disallowNormalClicks = false; 
	end

	self.SelectedOtherCheck:SetShown(selectedOther);
	self.SelectedOtherCheck:SetDesaturated(not unlocked);

	self.Icon:SetTexture(icon);

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end
end

function PvpTalentButtonMixin:SetOwningFrame(frame)
	self.owner = frame;
end

function PvpTalentButtonMixin:OnClick()
	if (IsModifiedClick("CHATLINK")) then
		local _, name = GetPvpTalentInfoByID(self.talentID);
		local link = GetPvpTalentLink(self.talentID);
		HandleGeneralTalentFrameChatLink(self, name, link);
		return;
	end

	if (not self.owner) then
		return;
	end

	if(not self.disallowNormalClicks) then 
		self.owner:SelectTalentForSlot(self.talentID, self.owner.selectedSlotIndex);
	end
end

function PvpTalentButtonMixin:OnEnter()
	if (C_SpecializationInfo.IsPvpTalentLocked(self.talentID) and select(7,GetPvpTalentInfoByID(self.talentID))) then
		C_SpecializationInfo.SetPvpTalentLocked(self.talentID, false);
		self.New:Hide();
		self.NewGlow:Hide();
	end

	if (not self.owner) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetPvpTalent(self.talentID, false, GetActiveSpecGroup(true), self.owner.selectedSlotIndex);
	GameTooltip:Show();
end

BobUI_PvpTalentWarmodeButtonMixin = {};

function BobUI_PvpTalentWarmodeButtonMixin:OnShow()
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PVP_WARMODE_UNLOCK)) then
		local helpTipInfo = {
			text = WAR_MODE_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_PVP_WARMODE_UNLOCK,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -4,
		};
		local parent = self:GetParent();
		HelpTip:Show(parent, helpTipInfo, parent.InvisibleWarmodeButton);
	end
	self:Update();
end

function BobUI_PvpTalentWarmodeButtonMixin:OnHide()
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED");
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
	self:UnregisterEvent("ZONE_CHANGED");
end

function BobUI_PvpTalentWarmodeButtonMixin:OnEvent(event, ...)
	if (event == "PLAYER_FLAGS_CHANGED") then
		local previousValue = self.predictedToggle:Get();
		self.predictedToggle:UpdateCurrentValue();
		self.predictedToggle:Clear();
		if (C_PvP.IsWarModeDesired() ~= previousValue) then
			self:Update();
		end
	elseif ((event == "ZONE_CHANGED") or (event == "ZONE_CHANGED_NEW_AREA")) then
		self:Update();
	end
end

function BobUI_PvpTalentWarmodeButtonMixin:SetUp()
	self.predictedToggle = CreatePredictedToggle(
		{
			["toggleFunction"] = function()
				C_PvP.ToggleWarMode();
			end,
			["getFunction"] = function()
				return C_PvP.IsWarModeDesired();
			end,
		}
	);
end

function BobUI_PvpTalentWarmodeButtonMixin:GetWarModeDesired()
	if BobUI_Globals["LOADED"] == false then return end
	return self.predictedToggle:Get();
end

function BobUI_PvpTalentWarmodeButtonMixin:Update()
	if BobUI_Globals["LOADED"] == false then return end
	self:SetEnabled(not IsInInstance());
	local frame = self:GetParent();
	local isPvp = self.predictedToggle:Get();
	local disabledAdd = isPvp and "" or "-disabled";
	local swordsAtlas = "pvptalents-warmode-swords"..disabledAdd;
	frame.InvisibleWarmodeButton.Swords:SetAtlas(swordsAtlas);

	self:GetParent():UpdateModelScenes();

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end
end

function BobUI_PvpTalentWarmodeButtonMixin:OnClick()
	if (C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired())) then
		
		local warmodeEnabled = self.predictedToggle:Get();

		self.predictedToggle:Toggle();

		self:Update();

		HelpTip:Acknowledge(self:GetParent(), WAR_MODE_TUTORIAL);
	end
end

function BobUI_PvpTalentWarmodeButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, PVP_LABEL_WAR_MODE);
	if C_PvP.IsWarModeActive() or self:GetWarModeDesired() then
		GameTooltip_AddInstructionLine(GameTooltip, PVP_WAR_MODE_ENABLED);
	end
	local wrap = true;
	local warModeRewardBonus = C_PvP.GetWarModeRewardBonus();
	GameTooltip_AddNormalLine(GameTooltip, PVP_WAR_MODE_DESCRIPTION_FORMAT:format(warModeRewardBonus), wrap);

	local canToggleWarmode = C_PvP.CanToggleWarMode(true);
	local canToggleWarmodeOFF = C_PvP.CanToggleWarMode(false);

	if(not canToggleWarmode or not canToggleWarmodeOFF) then

		local warmodeErrorText;

		if(not C_PvP.CanToggleWarModeInArea()) then
			if(self:GetWarModeDesired()) then
				if(not canToggleWarmodeOFF and not IsResting()) then
					warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA or PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA;
				end
			else
				if(not canToggleWarmode) then
					warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE;
				end
			end
		end

		if(warmodeErrorText) then
			GameTooltip_AddColoredLine(GameTooltip, warmodeErrorText, RED_FONT_COLOR, wrap);
		elseif (UnitAffectingCombat("player")) then
			GameTooltip_AddColoredLine(GameTooltip, SPELL_FAILED_AFFECTING_COMBAT, RED_FONT_COLOR, wrap);
		end
	end
		
	GameTooltip:Show();
end

BobUI_PvpTalentListMixin = {};

function BobUI_PvpTalentListMixin:OnLoad()
	--ButtonFrameTemplate_ShowButtonBar(self);
	--FrameTemplate_SetAtticHeight(self, 8);
end

function BobUI_PvpTalentListMixin:Update()
	local slotIndex = self:GetParent().selectedSlotIndex;
	
	if (slotIndex) then
		local scrollFrame = self.ScrollFrame;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local numButtons = #scrollFrame.buttons;
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex);
		if not slotInfo then
			return;
		end
		local numTalents = #slotInfo.availableTalentIDs;
		local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs();
		local availableTalentIDs = slotInfo.availableTalentIDs;

		table.sort(availableTalentIDs, function(a, b)
			local unlockedA = select(7,GetPvpTalentInfoByID(a));
			local unlockedB = select(7,GetPvpTalentInfoByID(b));

			if (unlockedA ~= unlockedB) then
				return unlockedA;
			end

			if (not unlockedA) then
				local reqLevelA = C_SpecializationInfo.GetPvpTalentUnlockLevel(a);
				local reqLevelB = C_SpecializationInfo.GetPvpTalentUnlockLevel(b);

				if (reqLevelA ~= reqLevelB) then
					return reqLevelA < reqLevelB;
				end
			end

			local selectedOtherA = tContains(selectedPvpTalents, a) and slotInfo.selectedTalentID ~= a;
			local selectedOtherB = tContains(selectedPvpTalents, b) and slotInfo.selectedTalentID ~= b;

			if (selectedOtherA ~= selectedOtherB) then
				return selectedOtherB;
			end

			return a < b;
		end);
		local selectedTalentID = slotInfo.selectedTalentID;

		local counter = 0

		for i = 1, numButtons do
			local button = scrollFrame.buttons[i];
			local index = offset + i;
			if (index <= numTalents) then
				local talentID = availableTalentIDs[index];
				local selectedHere = selectedTalentID == talentID;
				local selectedOther = tContains(selectedPvpTalents, talentID) and not selectedHere;

				button:SetOwningFrame(self:GetParent());
				button:SetPvpTalent(talentID);
				button:Update(selectedHere, selectedOther);
				button:SetSize(BobUI_Settings["SpellIconSize"], BobUI_Settings["SpellIconSize"])
				button:Show();
				if i ~= 1 then
					if counter == 0 then 
						button:SetPoint("TOPLEFT", scrollFrame.buttons[i-1], "TOPRIGHT", 2, 0);
						counter = 1 
					else 
						button:SetPoint("TOP", scrollFrame.buttons[i-2], "BOTTOM", 0, -2);
						counter = 0 
					end
				end
			else
				button:Hide();
			end
		end

		local totalHeight = ceil(numTalents / 2) * (BobUI_Settings["SpellIconSize"] + 2);
		scrollFrame:SetWidth((BobUI_Settings["SpellIconSize"] + 2)*2)
		scrollFrame.scrollChild:SetWidth((BobUI_Settings["SpellIconSize"] + 2)*2)
		scrollFrame:GetParent():SetSize((BobUI_Settings["SpellIconSize"] + 2)*2, totalHeight)

		HybridScrollFrame_Update(scrollFrame, totalHeight, totalHeight);
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



--[[
TalentPresets[Class_ID][Specialization_ID][Preset_Name] = {
	["Row1"] = {
		["Selected_Column"],
		["Selected_Column_Talent_ID"]
	},
	["Row2"] = {
		["Selected_Column"],
		["Selected_Column_Talent_ID"]
	}
	... ["Row7"] = ...
}
]]--


SELECTED_PRESET_BUTTON = nil
SELECTED_PRESET_DATA = {}
SELECTED_HEART_PRESET_DATA = {}

function getClassName(classFileName)
	for i=1, 12 do
		local Name, FileName, ID = GetClassInfo(i)

		if FileName == classFileName then return Name, ID end
	end
end

function updatePresetData()
	if SELECTED_PRESET_BUTTON ~= nil then
		button = SELECTED_PRESET_BUTTON

		local classFileName = button.classFileName
		local className, classID = getClassName(classFileName)
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

	button = self

	local classFileName = button.classFileName
	local className, classID = getClassName(classFileName)
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
				local className, classID = getClassName(k1)
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

function BobUI_PlayerTalentButton_OnMouseUP(self, mBtn)
	if mBtn == "RightButton" then
		local _, tName, _, selected, _, SpellID = GetTalentInfo(self.tier, self.column, 1);
		SELECTED_PRESET_DATA[self.tier] = {self.column, SpellID}
		updatePresetData()
	end
end
