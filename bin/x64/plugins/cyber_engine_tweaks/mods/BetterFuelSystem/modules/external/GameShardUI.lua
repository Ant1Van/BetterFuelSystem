GameShardUI = { 
    description = "Shard UI Buttons"
}

function GameShardUI.createButton(name, text, scaleToText)
	
	local totalLinesForText = 0
	
	if text ~= nil then 
		local buttonTextWrapped = wrap(text, 20)
		
		for _, btnWrapTxt in pairs(buttonTextWrapped) do
			totalLinesForText = totalLinesForText + 1
		end
	end
	
	local sizeForButton = 100.0
	
	if scaleToText == true and totalLinesForText > 2 then
		sizeForButton = 50.0*totalLinesForText
	end

	local button = inkCanvas.new()
	button:SetName(name)
	button:SetSize(400.0, sizeForButton)
	button:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
	button:SetInteractive(true)

	local bg = inkImage.new()
	bg:SetName('bg')
	bg:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas'))
	bg:SetTexturePart('cell_bg')
	bg:SetTintColor(HDRColor.new({ Red = 0.054902, Green = 0.054902, Blue = 0.090196, Alpha = 1.0 }))
	bg:SetOpacity(0.8)
	bg:SetAnchor(inkEAnchor.Fill)
	bg.useNineSliceScale = true
	bg.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	bg:SetMargin(inkMargin.new({ left = -10.0, top = -2.0, right = -10.0, bottom = -2.0 }))
	bg:Reparent(button, -1)

	local fill = inkImage.new()
	fill:SetName('fill')
	fill:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas'))
	fill:SetTexturePart('cell_bg')
	fill:SetTintColor(HDRColor.new({ Red = 1.1761, Green = 0.3809, Blue = 0.3476, Alpha = 1.0 }))
	fill:SetOpacity(0.0)
	fill:SetAnchor(inkEAnchor.Fill)
	fill.useNineSliceScale = true
	fill.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	fill:SetMargin(inkMargin.new({ left = -10.0, top = -2.0, right = -10.0, bottom = -2.0 }))
	fill:Reparent(button, -1)

	local frame = inkImage.new()
	frame:SetName('frame')
	frame:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas'))
	frame:SetTexturePart('cell_fg')
	frame:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
	frame:SetOpacity(0.3)
	frame:SetAnchor(inkEAnchor.Fill)
	frame.useNineSliceScale = true
	frame.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	frame:SetMargin(inkMargin.new({ left = -10.0, top = -2.0, right = -10.0, bottom = -2.0 }))
	frame:Reparent(button, -1)

	--local label = inkText.new()
	--label:SetName('label')
	--label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
	--label:SetFontStyle('Medium')
	--label:SetFontSize(40)
	--label:SetLetterCase(textLetterCase.UpperCase)
	--label:SetTintColor(HDRColor.new({ Red = 1.1761, Green = 0.3809, Blue = 0.3476, Alpha = 1.0 }))
	--label:SetAnchor(inkEAnchor.Fill)
	--label:SetHorizontalAlignment(textHorizontalAlignment.Center)
	--label:SetVerticalAlignment(textVerticalAlignment.Center)
	
	if text ~= nil then 
		local buttonTextWrapped = wrap(text, 20)
		local totalTextWrapped = ""
		local isFirst = true
		local totalLines = 0
		local totalLinesShown = 0
		
		for _, btnWrapTxt in pairs(buttonTextWrapped) do
			if btnWrapTxt ~= "" then
				totalLines = totalLines + 1
			end
		end
		
		for _, btnWrapTxt in pairs(buttonTextWrapped) do
			if btnWrapTxt ~= "" then
				local label = inkText.new()
				local labelName = 'label' .. tostring(totalLinesShown+1)
				label:SetName(labelName)
				label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
				label:SetFontStyle('Medium')
				label:SetFontSize(40)
				label:SetLetterCase(textLetterCase.UpperCase)
				label:SetTintColor(HDRColor.new({ Red = 1.1761, Green = 0.3809, Blue = 0.3476, Alpha = 1.0 }))
				label:SetAnchor(inkEAnchor.Fill)
				label:SetHorizontalAlignment(textHorizontalAlignment.Center)
				label:SetVerticalAlignment(textVerticalAlignment.Center)
				local totalTop = -(40.0 * (totalLines-1)) + (80 * totalLinesShown)
				label:SetMargin(inkMargin.new({ left = 0.0, top = totalTop, right = 0.0, bottom = 0.0 }))
				label:Reparent(button, -1)
				
				totalLinesShown = totalLinesShown + 1
				
				if isFirst == true then
					--totalTextWrapped = btnWrapTxt
					label:SetText(btnWrapTxt)

					isFirst = false
				else
					--totalTextWrapped = totalTextWrapped .. '\n' .. btnWrapTxt
					label:SetText(btnWrapTxt)
				end
			end
		end
		--label:SetText(totalTextWrapped)
		--label:SetText(text)
	else
		--label:SetText(text)
	end
	--label:Reparent(button, -1)
	
	return button
end

function GameShardUI.createBox(name, isHollow)
	local box = inkCanvas.new()
	box:SetName(name)
	box:SetSize(400.0, 100.0)
	box:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
	box:SetInteractive(true)

	local bg = inkImage.new()
	if isHollow then
		bg:SetName('bg')
		bg:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas'))
		bg:SetTexturePart('cell_bg')
		bg:SetTintColor(HDRColor.new({ Red = 0.054902, Green = 0.054902, Blue = 0.090196, Alpha = 1.0 }))
		bg:SetOpacity(0.8)
		bg:SetAnchor(inkEAnchor.Fill)
		bg.useNineSliceScale = true
		bg.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
		bg:SetMargin(inkMargin.new({ left = -10.0, top = -2.0, right = -10.0, bottom = -2.0 }))
		bg:Reparent(box, -1)
	else
		bg:SetName('bg')
		bg:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas'))
		bg:SetTexturePart('cell_bg')
		bg:SetTintColor(HDRColor.new({ Red = 0.054902, Green = 0.054902, Blue = 0.090196, Alpha = 1.0 }))
		bg:SetOpacity(1)
		bg:SetAnchor(inkEAnchor.Fill)
		bg.useNineSliceScale = true
		bg.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
		bg:SetMargin(inkMargin.new({ left = -10.0, top = -2.0, right = -10.0, bottom = -2.0 }))
		bg:Reparent(box, -1)
	end
	
	local fill = inkImage.new()
	fill:SetName('fill')
	fill:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas'))
	fill:SetTexturePart('cell_bg')
	fill:SetTintColor(HDRColor.new({ Red = 1.1761, Green = 0.3809, Blue = 0.3476, Alpha = 1.0 }))
	fill:SetOpacity(0.0)
	fill:SetAnchor(inkEAnchor.Fill)
	fill.useNineSliceScale = true
	fill.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	fill:SetMargin(inkMargin.new({ left = -10.0, top = -2.0, right = -10.0, bottom = -2.0 }))
	fill:Reparent(box, -1)

	local frame = inkImage.new()
	frame:SetName('frame')
	frame:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas'))
	frame:SetTexturePart('cell_fg')
	frame:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
	frame:SetOpacity(0.3)
	frame:SetAnchor(inkEAnchor.Fill)
	frame.useNineSliceScale = true
	frame.nineSliceScale = inkMargin.new({ left = 0.0, top = 0.0, right = 10.0, bottom = 0.0 })
	frame:SetMargin(inkMargin.new({ left = -10.0, top = -2.0, right = -10.0, bottom = -2.0 }))
	frame:Reparent(box, -1)

	return box
end

function GameShardUI.setButtonText(button, text)
	
	--local label = button:GetWidgetByIndex(0)
	--local label = button:GetWidgetByPathName(StringToName('label'))
		
	if text ~= nil then 
		local buttonTextWrapped = wrap(text, 20)
		local totalTextWrapped = ""
		local isFirst = true
		local totalLines = 0
		
		for _, btnWrapTxt in pairs(buttonTextWrapped) do
			if btnWrapTxt ~= "" then
				totalLines = totalLines + 1
			end
		end
		
		local totalLinesFound = 0
		local foundLastText = false
		
		while foundLastText == false do
			
			local labelName = 'label' .. tostring(totalLinesFound+1)
			local label = button:GetWidgetByPathName(StringToName(labelName))
			
			if (label ~= nil) then
				button:RemoveChild(label)
				totalLinesFound = totalLinesFound + 1
			else
				print('found after' .. tostring(totalLinesFound))
				foundLastText = true
			end
		end
		
		--[[
		for _, btnWrapTxt in pairs(buttonTextWrapped) do
			if btnWrapTxt ~= "" then
				totalLinesShown = totalLinesShown + 1
				
				if isFirst == true then
					--totalTextWrapped = btnWrapTxt
					label:SetText(btnWrapTxt)

					isFirst = false
				else
					--totalTextWrapped = totalTextWrapped .. '\n' .. btnWrapTxt
					label:SetText(btnWrapTxt)
				end
			end
		end
		--]]
		
		if text ~= nil then 
			local buttonTextWrapped = wrap(text, 20)
			local totalTextWrapped = ""
			local isFirst = true
			local totalLines = 0
			local totalLinesShown = 0
			
			for _, btnWrapTxt in pairs(buttonTextWrapped) do
				if btnWrapTxt ~= "" then
					totalLines = totalLines + 1
				end
			end
			
			for _, btnWrapTxt in pairs(buttonTextWrapped) do
				if btnWrapTxt ~= "" then
					local label = inkText.new()
					local labelName = 'label' .. tostring(totalLinesShown+1)
					label:SetName(labelName)
					label:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
					label:SetFontStyle('Medium')
					label:SetFontSize(40)
					label:SetLetterCase(textLetterCase.UpperCase)
					label:SetTintColor(HDRColor.new({ Red = 1.1761, Green = 0.3809, Blue = 0.3476, Alpha = 1.0 }))
					label:SetAnchor(inkEAnchor.Fill)
					label:SetHorizontalAlignment(textHorizontalAlignment.Center)
					label:SetVerticalAlignment(textVerticalAlignment.Center)
					local totalTop = -(40.0 * (totalLines-1)) + (80 * totalLinesShown)
					label:SetMargin(inkMargin.new({ left = 0.0, top = totalTop, right = 0.0, bottom = 0.0 }))
					label:Reparent(button, -1)
					
					totalLinesShown = totalLinesShown + 1
					
					if isFirst == true then
						--totalTextWrapped = btnWrapTxt
						label:SetText(btnWrapTxt)

						isFirst = false
					else
						--totalTextWrapped = totalTextWrapped .. '\n' .. btnWrapTxt
						label:SetText(btnWrapTxt)
					end
				end
			end
			--label:SetText(totalTextWrapped)
			--label:SetText(text)
		else
			--label:SetText(text)
		end
		
		--label:SetText(totalTextWrapped)
		--label:SetText(text)
	end
end

function wrap(str, limit)
  limit = limit
  local here = 1
  local buf = ""
  local t = {}
  str:gsub("(%s*)()(%S+)()",
  function(sp, st, word, fi)
        if fi-here > limit then
           --# Break the line
           here = st
           table.insert(t, buf)
           buf = word
        else
           buf = buf..sp..word  --# Append
        end
  end)
  --# Tack on any leftovers
  if(buf ~= "") then
        table.insert(t, buf)
  end
  --print(t[1])
  return t
end

return GameShardUI