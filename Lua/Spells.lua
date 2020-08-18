function handleChatAndMacroLinks(type, relevantID)
	
end

function getCorrectSpellIDForDrag(spellID)
	
	if set(53271, 62305, 272682, 264735, 281195, 264667, 272679)[spellID] then
		spellID = 272651 -- command pet
	elseif set(271045, 270323, 270335)[spellID] then
		spellID = 259495 -- shrapnel bomb
	end

    return spellID
end

function pickupAbility(abilityID, abilityType)
	abilityID = getCorrectSpellIDForDrag(abilityID)

	-- PickupSpell
	-- PickupPvpTalent
	-- PickupTalent
	-- PickupSpellBookItem

end

function GetNumSpellsForSpellBook(SPELL_BOOK)
	
	local name, texture, offset, numSlots, isGuild, offSpecID, shouldHide, specID = GetSpellTabInfo(SPELL_BOOK);

	if SPELL_BOOK == 6 then
		numSlots = select(1, HasPetSpells())
	end

	if SPELL_BOOK == 7 then -- professions
		
		numSlots = 0

		for i=1,5 do
			if (BobUI_Globals["PROFESSIONS"][i] ~= nil) then
				numSlots = numSlots + BobUI_Globals["PROFESSIONS"][i]["numSpells"]
			end
		end

	end


	return numSlots
end