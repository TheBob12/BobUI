function BobUI_activatePreset(presetName, silent, isHookFunction)
    if silent == nil then silent = false end
    if isHookFunction == nil then isHookFunction = false end

    local presetFound = false

    if TalentPresets[BobUI_Globals["CHARACTER"]["classFileName"]][BobUI_Globals["CHARACTER"]["currentSpecializationID"]][presetName] ~= nil then
        presetFound = true

        for k, v in pairs(TalentPresets[BobUI_Globals["CHARACTER"]["classFileName"]][BobUI_Globals["CHARACTER"]["currentSpecializationID"]][presetName]) do
            local tID, tName, _, selected, available, SpellID = GetTalentInfo(k, v[1], GetActiveSpecGroup());

            if tID then
                LearnTalent(tID)
            end
        end
    end

    if not isHookFunction then -- prevent endless loop between the hook with changing sets and activating presets.
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