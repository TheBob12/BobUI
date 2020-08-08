function getCorrectSpellIDForDrag(spellID)
	
	if set(53271, 62305, 272682, 264735, 281195, 264667, 272679)[spellID] then
		spellID = 272651 -- command pet
	elseif set(271045, 270323, 270335)[spellID] then
		spellID = 259495 -- shrapnel bomb
	end

    return spellID
end