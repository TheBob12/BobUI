BobUI_FRAMES = { -- reference, for quickly changing settings.
    ["BACKGROUND"] = {
		"BobUI_AbilityTabBackground"
	},
    ["HEADERS"] = {
		"BobUI_TabTitleText"
	},
    ["LABELS"] = {
		"BobTabPage1ActivesTitle",
		"BobTabPage1PassivesTitle",
		"BobUI_PlayerTalentFrameTalentsTalentsTitle",
		"BobUI_PlayerTalentFrameTalentsBobUI_PvpTalentFramePVPTalentsTitle",
		"BobUI_PlayerTalentFrameTalentsEssencesTitleText",
		"BobTabPage2SetName"
	},
	["BODY"] = {
		"BobTabPage2TalentSetInfo",
	},
    ["hSEPARATORS"] = {

	},
    ["vSEPARATORS"] = {

	}
}


-- list containing dimensions that decide the size of the Bob UI frame. 
-- This will allow implementing wow expansion related "plug-ins" to the spell book, like the heart of azeroth - without much effort.
-- Not in use currently.
BobUI_SizeModifiers = {}


function BobUI_updateSize()
	
end

function GetBorderColor(borderColorType)
    if borderColorType == nil then borderColorType = "BorderColorActive" end

	if BobUI_Settings[borderColorType] == nil then 
		return BobUI_Globals["CHARACTER"][borderColorType]["r"], BobUI_Globals["CHARACTER"][borderColorType]["g"], BobUI_Globals["CHARACTER"][borderColorType]["b"], BobUI_Globals["CHARACTER"][borderColorType]["a"]
	else
		return BobUI_Settings[borderColorType]["r"], BobUI_Settings[borderColorType]["g"], BobUI_Settings[borderColorType]["b"], BobUI_Settings[borderColorType]["a"]
    end
end

function setupColorButton(self)
	local colorButton = self

	self:SetSize(self:GetWidth() + 40, self:GetHeight() + 10)
	self.bg:SetSize(self:GetSize())

	colorButton.SetColorRGBA = function( self, newR, newG, newB, newA )
		if colorButton.Background then
			if colorButton.affectedFrames ~= nil then
				for k,v in pairs(colorButton.affectedFrames) do
					if colorButton.Separator then
						if _G[v].borderLeft ~= nil then
							_G[v].borderLeft:SetColorTexture(newR, newG, newB, newA)
						end
						if _G[v].borderRight ~= nil then
							_G[v].borderRight:SetColorTexture(newR, newG, newB, newA)
						end
						if _G[v].hSeparatorTop ~= nil then
							_G[v].hSeparatorTop:SetColorTexture(newR, newG, newB, newA)
						end
						if _G[v].hSeparatorBottom ~= nil then
							_G[v].hSeparatorBottom:SetColorTexture(newR, newG, newB, newA)
						end
					else
						if _G[v].bg ~= nil then
							_G[v].bg:SetColorTexture(newR, newG, newB, newA)
						end
					end
				end
			end
		else
			if colorButton.affectedFrames ~= nil then
				for k,v in pairs(colorButton.affectedFrames) do
					if _G[v].category ~= nil then
						_G[v].category:SetTextColor(newR, newG, newB, newA)
					end
					if _G[v].text ~= nil then
						_G[v].text:SetTextColor(newR, newG, newB, newA)
					end
				end
			end
		end
		
		if not ColorPickerFrame:IsShown() then
			if colorButton.Background then
				if colorButton.Separator then
					BobUI_Settings["SeparatorColor"] = {
						["r"] = newR, 
						["g"] = newG, 
						["b"] = newB, 
						["a"] = newA
					}
				else
					BobUI_Settings["BackgroundColor"] = {
						["r"] = newR, 
						["g"] = newG, 
						["b"] = newB, 
						["a"] = newA
					}
				end
			else
				BobUI_Settings["TextColor"] = {
					["r"] = newR, 
					["g"] = newG, 
					["b"] = newB, 
					["a"] = newA
				}
			end
		end
	end
	
	colorButton.cancelFunc = function()
		if colorButton.r ~= nil and colorButton.g ~= nil and colorButton.b ~= nil then

			colorButton:SetColorRGBA(ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b, ColorPickerFrame.previousValues.opacity)
		
		end
	end

	
	colorButton.swatchFunc = function(info)
		if ColorPickerFrame:GetColorRGB() ~= nil then
			local r,g,b = ColorPickerFrame:GetColorRGB()

			colorButton:SetColorRGBA( r,g,b, 1 - OpacitySliderFrame:GetValue())
		end
	end
	
	colorButton:SetScript( "OnClick", function( self )
		if ColorPickerFrame:IsShown() then
			ColorPickerFrame:Hide()
		else
			self.r, self.g, self.b = r, g, b
			ColorPickerFrame:Hide()

			local info = UIDropDownMenu_CreateInfo();
			local colors = {}

			if colorButton.Background then
				if colorButton.Separator then
					if BobUI_Settings["SeparatorColor"] == nil then BobUI_Settings["SeparatorColor"] = BobUI_Settings_Recommended["SeparatorColor"] end
					colors = BobUI_Settings["SeparatorColor"]
				else
					if BobUI_Settings["BackgroundColor"] == nil then BobUI_Settings["BackgroundColor"] = BobUI_Settings_Recommended["BackgroundColor"] end
					colors = BobUI_Settings["BackgroundColor"]
				end
				
			else
				if BobUI_Settings["TextColor"] == nil then BobUI_Settings["TextColor"] = BobUI_Settings_Recommended["TextColor"] end
				colors = BobUI_Settings["TextColor"]
			end

			info.r, info.g, info.b = colors["r"], colors["g"], colors["b"]

			info.hasOpacity = 1
			info.opacity = 1 - colors["a"]

			info.swatchFunc = colorButton.swatchFunc
			info.func = colorButton.swatchFunc
			info.opacityFunc = colorButton.swatchFunc
			info.cancelFunc = colorButton.cancelFunc

			OpenColorPicker(info);
			ColorPickerFrame:SetPoint("TOPRIGHT", colorButton, "BOTTOMRIGHT", 0, -10)
			ColorPickerFrame:SetFrameStrata( "TOOLTIP" )
			ColorPickerFrame:Raise()
		end
	end )
end


function addFrameToBobUIFrames(frameName, frameType)
    if frameType ~= nil and frameName ~= nil then
        table.insert(BobUI_FRAMES[frameType], frameName);
    end
end

function displayColoringSettings(frameType)
    
end

function resizeFrames()

end