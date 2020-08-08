function editBox_OnKeyUp(self, event)
	if event == "ESCAPE" then
		self:ClearFocus()
	end
end

function editBoxKeyDown(self, event)
	local editBoxText = self:GetText():gsub('[^0-9+.]', '')

	if event == "ENTER" then
		if editBoxText == "" or ((self.settingName == "FontSizeHeader" or self.settingName == "FontSizeBody") and tonumber(editBoxText) < 1) then
			if self.settingName == "Scaling" then 
				editBoxText = 768 / string.match(GetCVar("gxWindowedResolution" ), "%d+x(%d+)")
			else
				editBoxText = BobUI_Settings_Recommended[self.settingName]
			end
		end
		
		self.settingValue = editBoxText
		self:SetText(editBoxText)
		applySetting(self)
		self:ClearFocus()


		if BobUI_AbilityTab:IsShown() then BobUI_AbilityTab:Hide(); BobUI_AbilityTab:Show() end
	end
end