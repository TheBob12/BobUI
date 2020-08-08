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