BOBUI_DEV_MESSAGES = true;

BobUI_Globals = {
	["ADDON_PREFIX"] = "Bob UI",
    ["VIEWED_SPELL_BOOK"] = 2,
    ["VIEWED_SPELL_BOOK_NUM_SPELLS"] = nil;
    ["SHOW_BOBUI_ABILITY_TAB_AFTER_COMBAT"] = false,
    ["SPELL_BOOK_TYPE"] = "spells",
    ["CURRENT_FLYOUT"] = nil,
    ["VIEWED_TAB_ID"] = nil,
    ["PROFESSIONS"] = {},
	["CHARACTER"] = {},
	["roleNames"] = {
		["HEALER"] = HEALER,
		["DAMAGER"] = DAMAGER,
		["TANK"] = TANK
	},
	["LOADED"] = false,
	["PTR"] = false
}


BobUI_Settings_Recommended = {
	["BorderSize"] = 2,
	["SeparatorSize"] = 1,
	["SpellIconSize"] = 36,
	["TabIconSize"] = 36,
	["Scaling"] = (768 / string.match(GetCVar("gxWindowedResolution" ), "%d+x(%d+)")),
	["FontSizeHeader"] = 18,
	["FontSizeLabels"] = 14,
	["FontSizeBody"] = 14,
	["BackgroundColor"] = {
		["r"] = 0, 
		["g"] = 0, 
		["b"] = 0, 
		["a"] = 0.9
	},
	["SeparatorColor"] = {
		["r"] = 0.1, 
		["g"] = 0.1, 
		["b"] = 0.1, 
		["a"] = 1.0
	},
	["TextColor"] = {
		["r"] = 0.8, 
		["g"] = 0.8, 
		["b"] = 0.8, 
		["a"] = 1.0
    },
    ["SpellButtonsPerRow"] = 9,
    ["AzeriteButtonsPerRow"] = 3,
    ["PvpTalentsPerRow"] = 2,
	["NumberOfTabButtons"] = 8,
	["FontType"] = "Fonts\\ARIALN.ttf"
}
	--[[
	["BorderColorActive"] = {
		["r"] = 0.8, 
		["g"] = 0.8, 
		["b"] = 0.8, 
		["a"] = 1
    },
	["BorderColorSelected"] = {
		["r"] = 0.8, 
		["g"] = 0.8, 
		["b"] = 0.8, 
		["a"] = 0.4
	},
	--]]
	
function SetupBobUISettings() 
	if BobUI_Settings == nil then 
		BobUI_Settings = {}
		for k,v in pairs(BobUI_Settings_Recommended) do
			BobUI_Settings[k] = v
		end
	else
		for k,v in pairs(BobUI_Settings_Recommended) do
			if BobUI_Settings[k] == nil then 
				BobUI_Settings[k] = BobUI_Settings_Recommended[k]
			end
		end
	end
end

function toggleSpellBookSettings()
	local isShown = BobUI_SettingsFrame:IsShown()

	if isShown then BobUI_SettingsFrame:Hide() else BobUI_SettingsFrame:Show() end
end

function BobUI_applySetting(self) 
	BobUI_Settings[self.settingName] = self.settingValue

	if self.settingName == "Scaling" then
		BobUI_AbilityTab:SetScale(BobUI_Settings["Scaling"])
	end
end

function GetCurrentCharacterInfo() 
    local className, classFileName, classID = UnitClass("player")
	local classColorR, classColorG, classColorB = RAID_CLASS_COLORS[classFileName]:GetRGB()
    local classColorA = 1
    local playerLevel = UnitLevel("player") -- need to register an event to keep this up to date. 
	local numSpecs = GetNumSpecializationsForClassID(classID);
    local currentSpecID = GetSpecialization() -- need to register an event to keep this up to date. 
	local cSpecID, currentSpecName = GetSpecializationInfo(currentSpecID) -- need to register an event to keep this up to date. 
    local sex = UnitSex("player");
    

    BobUI_Globals["CHARACTER"] = {
        ["className"] = className,
        ["classFileName"] = classFileName,
        ["classID"] = classID,
        ["classColor"] = {
            ["r"] = classColorR, 
            ["g"] = classColorG, 
            ["b"] = classColorB, 
            ["a"] = classColorA
        },
        ["playerLevel"] = playerLevel,
        ["numSpecializations"] = numSpecs,
        ["currentSpecializationIndex"] = currentSpecID,
        ["currentSpecializationID"] = cSpecID,
        ["currentSpecializationName"] = currentSpecName,
		["sex"] = sex,
		["BorderColorActive"] = {
			["r"] = classColorR, 
			["g"] = classColorG, 
			["b"] = classColorB, 
			["a"] = classColorA
		},
		["BorderColorSelected"] = {
			["r"] = classColorR, 
			["g"] = classColorG, 
			["b"] = classColorB, 
			["a"] = 0.4
		}
	}

	if TalentMicroButtonAlert == nil then BobUI_Globals["PTR"] = true end -- testing against a variable that that exists in BFA, but not PTR
end