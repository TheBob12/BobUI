local lastRefreshed = 0; -- SKILL_LINES_CHANGED is fired multiple times. There is no need to update professions more than once within a second. 

function BobUI_FormatProfession(PROFESSION_INDEX, PROFESSION_ID)
	if PROFESSION_ID == nil then BobUI_Globals["PROFESSIONS"][PROFESSION_INDEX] = nil; return end 
	local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset, skillLineName = GetProfessionInfo(PROFESSION_ID);
	
	BobUI_Globals["PROFESSIONS"][PROFESSION_INDEX] = {
		["name"] = name,
		["texture"] = texture,
		["rank"] = rank,
		["maxRank"] = maxRank,
		["numSpells"] = numSpells,
		["spelloffset"] = spelloffset,
		["skillLine"] = skillLine,
		["rankModifier"] = rankModifier,
		["specializationIndex"] = specializationIndex,
		["specializationOffset"] = specializationOffset,
		["skillLineName"] = skillLineName
	}
end

function BobUI_UpdateProfessions()
	local currentTime = GetTime()

	if lastRefreshed < currentTime - 2 then
		local prof1, prof2, arch, fish, cook = GetProfessions();

		BobUI_FormatProfession(1, prof1);
		BobUI_FormatProfession(2, prof2);
		BobUI_FormatProfession(3, cook);
		BobUI_FormatProfession(4, fish);
		BobUI_FormatProfession(5, arch);

		lastRefreshed = currentTime
	end

	if BobUI_Globals["PROFESSIONS"][1] ~= nil then
		BobUI_specButtons.specButton7.specIcon:SetTexture(BobUI_Globals["PROFESSIONS"][1]["texture"])
	else
		BobUI_specButtons.specButton7.specIcon:SetTexture("Interface/Icons/TRADE_ARCHAEOLOGY_OGRE2HANDEDHAMMER");
	end
end

function getProfessionOffset(li)
	local returned = 0
	local spellCount = 0
	local numSpells = 0
	local isFirstOfProfession = false

	local learnedProfessionAbilityLocations = {}

	for i=1,5 do
		if BobUI_Globals["PROFESSIONS"][i] ~= nil then
			spellCount = spellCount + BobUI_Globals["PROFESSIONS"][i]["numSpells"]
			local numSpellsForProfession = BobUI_Globals["PROFESSIONS"][i]["numSpells"]

			for i1=1,numSpellsForProfession do
				table.insert(learnedProfessionAbilityLocations, i)
			end
		end
	end


	if BobUI_Globals["PROFESSIONS"][learnedProfessionAbilityLocations[li]] ~= nil then
		returned = BobUI_Globals["PROFESSIONS"][learnedProfessionAbilityLocations[li]]["spelloffset"]
		numSpells = BobUI_Globals["PROFESSIONS"][learnedProfessionAbilityLocations[li]]["numSpells"]

		if learnedProfessionAbilityLocations[li-1] ~= nil then
			if learnedProfessionAbilityLocations[li-1] ~= learnedProfessionAbilityLocations[li] then
				isFirstOfProfession = true
			end
		else
			isFirstOfProfession = true
		end
	end

	return returned - li + 1 + (isFirstOfProfession and 0 or 1), isFirstOfProfession, learnedProfessionAbilityLocations[li]
end