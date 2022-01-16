

-- Backend vars
local lastHealth = 1
local newHealth = 1
local modHealth = 1
local healthTimeout = 0

-- Options.lua
healthMultiplierView = 1*60
healthMultiplier=1*60
healingSpeed = 0.0016*60000
healingSpeedView = 0.001*60000
--healingTimeout = 120*2
--healingTimeoutView = 120*2
healingTimeout = 0
healingTimeoutView = 0

-- Settings
local changeHealthDrain = 0.5
local healthGain = 0.001
local healthGainTimeout = 120
local alwaysShowHealthBar = 1 -- 1 is false 2 is true
local godmode = false
local makeScreenRed = true

local godmodeKey = "G"

function init()
	-- Load config
	godmodeKey = GetString("savegame.mod.godmodeKey")
	if godmodeKey == "" or godmodeKey == nil then godmodeKey = "G" end
	
	alwaysShowHealthBar = GetInt("savegame.mod.alwaysShowHealthBar")
	if alwaysShowHealthBar < 1 then alwaysShowHealthBar = 1 end
	
	makeScreenRed = GetBool("savegame.mod.makeScreenRed")
	if makeScreenRed == nil then makeScreenRed = true end
	
	healthMultiplier = GetInt("savegame.mod.healthMultiplier")
	--DebugPrint(changeHealthDrain)
	if healthMultiplier == nil or healthMultiplier == 0 then healthMultiplier = 1.0 else healthMultiplier = healthMultiplier/100 end
	healthMultiplier = healthMultiplier*60
	--DebugPrint(changeHealthDrain)
	
	healingSpeed = GetInt("savegame.mod.healingSpeed")
	if healingSpeed == nil or healingSpeed == 0 then healingSpeed = 0.0016 else healingSpeed = healingSpeed/10000 end
	if GetInt("savegame.mod.healingSpeed") == 10000 then healingSpeed = 0 end
	healingSpeed=healingSpeed*60000
	
	healingTimeout = GetInt("savegame.mod.healingTimeout")
	if healingTimeout == nil or healingTimeout == 0 then healingTimeout = 0 end
	if GetInt("savegame.mod.healingTimeout") == 1000 then healingTimeout = 0 end
	healingTimeout=healingTimeout*2
end

function draw()
	-- Setup safe drawing area
	-- The drawing area is now 1920 by 1080 in the center of screen
	local x0, y0, x1, y1 = UiSafeMargins()
	UiTranslate(x0, y0)
	UiWindow(x1-x0, y1-y0, true)
		
	-- Credits
	UiPush()
		UiColor(1,1,1)
		UiFont("bold.ttf", 32)
		UiTranslate(UiCenter(), 128)
		UiAlign("center middle")
		UiText("Health Config mod by Jos Badpak")
	UiPop()
	
	--Draw buttons
	--[[
		
		local changeHealthDrain = 0.5
		local healthGain = 0.001
		local healthGainTimeout = 120
		local alwaysShowHealthBar = 2 -- 1 is false 2 is true
		local godmode = false
		local makeScreenRed = true
		
	]]--
	UiPush()
	UiTranslate(UiCenter(), 0)
	UiTranslate(0, UiHeight()-48)
	UiFont("regular.ttf", 26)
	UiAlign("center middle")
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	
		-- Toggle godmode key
		UiTranslate(0, -600)
		if UiTextButton("Toggle godmode key", 240, 40) then
			godmodeKey = ""
		end
		UiTranslate(128, 0)
		UiAlign("left middle")
		if godmodeKey == "" then
			UiText("Press any key")
		else
			UiText(godmodeKey)
		end
		
		-- Always show health bar
		UiAlign("center middle")
		UiTranslate(-128, 64)
		if UiTextButton("Always show health bar", 240, 40) then
			if alwaysShowHealthBar == 1 then
				alwaysShowHealthBar = 2
			else
				alwaysShowHealthBar = 1
			end
		end
		UiTranslate(128, 0)
		UiAlign("left middle")
		if alwaysShowHealthBar == 1 then
			UiText("False")
		else
			UiText("True")
		end
		
		-- Red screen on low health
		UiAlign("center middle")
		UiTranslate(-128, 64)
		if UiTextButton("Red screen on low health", 240, 40) then
			if makeScreenRed == true then
				makeScreenRed = false
			else
				makeScreenRed = true
			end
		end
		UiTranslate(128, 0)
		UiAlign("left middle")
		if makeScreenRed == true then
			UiText("True")
		else
			UiText("False")
		end
		
		-- Mark default
		--[[UiTranslate(-368, 128)
		UiColor(0,1,0)
		UiRect(2, 128)
		UiColor(1,1,1)
		UiTranslate(368,-128)]]--
		
		-- Health Multiplier
		UiAlign("center middle")
		UiTranslate(-128, 64)
		UiText("Health multiplier")
		UiColor(1,1,1)
		UiTranslate(-300, 32)
		healthMultiplier = UiSlider("ui/common/dot.png", "x", healthMultiplier, 0, 600)
		healthMultiplierView = healthMultiplier/60
		healthMultiplierView = math.floor(healthMultiplierView*100+0.5)/100
		UiTranslate(300, 0)
		UiRect(600, 4)
		UiAlign("left middle")
		UiTranslate(160, -32)
		if healthMultiplierView <= 0 then
			healthMultiplierView = 0.01
		end
		UiText(healthMultiplierView)
		
		-- Healing Speed
		UiAlign("center middle")
		UiTranslate(-32, 32)
		UiTranslate(-128, 32)
		UiText("Healing speed")
		UiColor(1,1,1)
		UiTranslate(-300, 32)
		healingSpeed = UiSlider("ui/common/dot.png", "x", healingSpeed, 0, 600)
		healingSpeedView = healingSpeed/60000
		healingSpeedView = math.floor(healingSpeedView*10000+0.5)/10000
		UiTranslate(300, 0)
		UiRect(600, 4)
		UiAlign("left middle")
		UiTranslate(160, -32)
		UiText(healingSpeedView)
		
		-- Healing Timeout
		UiAlign("center middle")
		UiTranslate(-32, 32)
		UiTranslate(-128, 32)
		UiText("Timeout before healing (frames)")
		UiColor(1,1,1)
		UiTranslate(-300, 32)
		healingTimeout = UiSlider("ui/common/dot.png", "x", healingTimeout, 0, 600)
		healingTimeoutView = healingTimeout/2
		healingTimeoutView = math.floor(healingTimeoutView+0.5)
		UiTranslate(300, 0)
		UiRect(600, 4)
		UiAlign("left middle")
		UiTranslate(160, -32)
		UiText(healingTimeoutView)
		UiTranslate(96, 0)
		UiText(math.floor(healingTimeoutView/6+0.5)/10)
		UiTranslate(32, 0)
		UiText("Seconds")
	UiPop()
	
	
	UiPush()
		UiTranslate(UiCenter(), UiHeight()-128)
		UiFont("regular.ttf", 26)
		UiAlign("center middle")
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	
	
		-- Default
		UiTranslate(256, 0)
		if UiTextButton("Default", 200, 40) then
			-- Options.lua
			healthMultiplierView = 1*60
			healthMultiplier=1*60
			healingSpeed = 0.0016*60000
			healingSpeedView = 0.001*60000
			healingTimeout = 0 --120*2
			healingTimeoutView = 0 --120*2

			-- Settings
			changeHealthDrain = 0.5
			healthGain = 0.001
			healthGainTimeout = 120
			alwaysShowHealthBar = 1 -- 1 is false 2 is true
			godmode = false
			makeScreenRed = true
			godmodeKey = "G"
		end
		
		-- Save
		UiTranslate(-256, 0)
		if UiTextButton("Save & close", 200, 40) then
			SetString("savegame.mod.godmodeKey", godmodeKey)
			SetInt("savegame.mod.alwaysShowHealthBar", alwaysShowHealthBar)
			SetBool("savegame.mod.makeScreenRed", makeScreenRed)
			if healthMultiplierView == 0 then healthMultiplierView = 1 end
			SetInt("savegame.mod.healthMultiplier", healthMultiplierView*100)
			if healingSpeedView == 0 then healingSpeedView = 1 end
			SetInt("savegame.mod.healingSpeed", healingSpeedView*10000)
			if healingTimeoutView == 0 then healingTimeoutView = 1000 end
			SetInt("savegame.mod.healingTimeout", healingTimeoutView)
			Menu()
		end
	
		-- Close
		UiTranslate(-256, 0)
		if UiTextButton("Close", 200, 40) then
			Menu()
		end
	UiPop()
	
	
	-- Draw Health bar
	--drawHealthBar()
	
	
	
end

function update(dt)
	if godmodeKey == nil or godmodeKey == "" then
		godmodeKey = InputLastPressedKey()
		--DebugPrint(godmodeKey)
	end
end

local damagePlayer = true

function tick(dt)
	if godmode == false then
	
		-- Damage player
		if damagePlayer == true then
			modHealth = modHealth - 0.002
			if modHealth <= 0.01 then
				damagePlayer = false
			end
		else
			
			-- Healing timeout
			if modHealth < 1 and healthTimeout > 0 then
				healthTimeout = healthTimeout - 1
			else
				-- Heal player
				if modHealth > 0 and modHealth < 1 then
					modHealth = modHealth + healthGain
					if modHealth >= 1 then
						healthTimeout = healthGainTimeout
					end
				end
			end
			
			if modHealth >= 1 then
				damagePlayer = true
			end
			
		end
	else
		-- Set godmode mode
		SetPlayerHealth(1)
	end
	
	-- Change godmode
	if InputReleased("interact") then
		if godmode == true then
			godmode = false
		else
			godmode = true
		end
	end
end

function drawHealthBar()
	-- Draw HEALTH text
	if modHealth > 0 and modHealth < alwaysShowHealthBar then 
		UiPush()
			-- Set correct color
			if modHealth < 0.3 then
				-- Red
				UiColor(1, 0, 0)
			--[[elseif modHealth < 0.8 then
				-- Yellow
				UiColor(1, 1, 1*modHealth)]]--
			end
			UiFont("bold.ttf", 24)
			UiTranslate(UiWidth()-144, UiHeight()-22)
			UiAlign("right")
			UiText("HEALTH")
		UiPop()
		
		-- Draw Health background
		UiPush()
			UiTranslate(UiWidth()-134, UiHeight()-40)
			UiColor(0, 0, 0, 0.6)
			if modHealth < 0 then 
				modHealth = -1
			end
			UiRect(108, 20)
		UiPop()
		

		-- Draw Health bar
		UiPush()
			UiTranslate(UiWidth()-132, UiHeight()-38)
			
			-- Set correct color
			if modHealth < 0.3 then
				-- Red
				UiColor(1, 0, 0)
			elseif modHealth < 0.8 then
				-- Yellow
				UiColor(1, 1, 1*modHealth)
			end
			
			-- Die when out of health
			if modHealth < 0 then 
				modHealth = -1
				SetPlayerHealth(0)
			end
			UiRect(104*modHealth, 16)
		UiPop()
	end
end