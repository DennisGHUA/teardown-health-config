

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
local changeHealthDrain = 1.0
local healthGain = 0.001
local healthGainTimeout = 120
local alwaysShowHealthBar = 1 -- 1 is false 2 is true
local godmode = false -- not used here
local screenEffectRed = "true"
local screenEffectBlur = "true"
local screenEffectDamage = "true"
local godmodeEnabledDefault = "false"
local godmodeHideText = "false"

local godmodeKey = "G"

function init()

	loadSettings()
	
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
		UiTranslate(UiCenter(), 64)
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
		local screenEffectRed = true
		
	]]--
	UiPush()
	UiTranslate(UiCenter(), 0)
	UiTranslate(0, UiHeight()-48)
	UiFont("regular.ttf", 26)
	UiAlign("center middle")
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	
		-- Enable godmode by default
		UiAlign("center middle")
		UiTranslate(0, -800)
		if UiTextButton("Enable godmode by default", 300, 40) then
			if godmodeEnabledDefault == "true" then
				godmodeEnabledDefault = "false"
			else
				godmodeEnabledDefault = "true"
			end
		end
		UiTranslate(180, 0)
		UiAlign("left middle")
		drawUiStatus(godmodeEnabledDefault)
		
		-- Hide godmode text
		UiAlign("center middle")
		UiTranslate(-180, 64)
		if UiTextButton("Fade away godmode text", 300, 40) then
			if godmodeHideText == "true" then
				godmodeHideText = "false"
			else
				godmodeHideText = "true"
			end
		end
		UiTranslate(180, 0)
		UiAlign("left middle")
		drawUiStatus(godmodeHideText)
	
		-- Toggle godmode key
		UiTranslate(-330, 64)
		UiAlign("left middle")
		if UiTextButton("Toggle godmode key", 300, 40) then
			godmodeKey = ""
		end
		UiTranslate(330, 0)
		UiAlign("left middle")
		if godmodeKey == "" then
			UiText("Press any key")
		else
			UiText(godmodeKey)
		end
		
		UiTranslate(0, 32)
		
		-- Always show health bar
		UiAlign("center middle")
		UiTranslate(-180, 64)
		if UiTextButton("Health bar always on screen", 300, 40) then
			if alwaysShowHealthBar == 1 then
				alwaysShowHealthBar = 2
			else
				alwaysShowHealthBar = 1
			end
		end
		UiTranslate(180, 0)
		UiAlign("left middle")
		if alwaysShowHealthBar == 1 then
			drawUiStatus(false)
		else
			drawUiStatus(true)
		end

		-- Screen blur on low health
		UiAlign("center middle")
		UiTranslate(-180, 64)
		if UiTextButton("Screen blur on low health", 300, 40) then
			if screenEffectBlur == "true" then
				screenEffectBlur = "false"
			else
				screenEffectBlur = "true"
			end
		end
		UiTranslate(180, 0)
		UiAlign("left middle")
		drawUiStatus(screenEffectBlur)

		-- Red screen on low health
		UiAlign("center middle")
		UiTranslate(-180, 64)
		if UiTextButton("Red screen on low health", 300, 40) then
			if screenEffectRed == "true" then
				screenEffectRed = "false"
			else
				screenEffectRed = "true"
			end
		end
		UiTranslate(180, 0)
		UiAlign("left middle")
		drawUiStatus(screenEffectRed)


		-- Screen damage effect
		UiAlign("center middle")
		UiTranslate(-180, 64)
		if UiTextButton("Red screen on any damage", 300, 40) then
			if screenEffectDamage == "true" then
				screenEffectDamage = "false"
			else
				screenEffectDamage = "true"
			end
		end
		UiTranslate(180, 0)
		UiAlign("left middle")
		drawUiStatus(screenEffectDamage)
		
		-- Mark default
		--[[UiTranslate(-368, 128)
		UiColor(0,1,0)
		UiRect(2, 128)
		UiColor(1,1,1)
		UiTranslate(368,-128)]]--
		
		UiTranslate(-32, 16)
		
		-- Health Multiplier
		UiAlign("left middle")
		UiTranslate(-128, 64)
		UiTranslate(-300, 0)
		UiText("Health multiplier")
		UiTranslate(300, 0)
		UiColor(1,1,1)
		UiTranslate(-300, 32)
		UiAlign("center middle")
		healthMultiplier = UiSlider("ui/common/dot.png", "x", healthMultiplier, 0, 600)
		healthMultiplierView = healthMultiplier/60
		healthMultiplierView = math.floor(healthMultiplierView*100+0.5)/100
		UiTranslate(300, 0)
		UiRect(600, 4)
		UiAlign("right middle")
		UiTranslate(160, -32)
		UiTranslate(140, 0)
		if healthMultiplierView <= 0 then
			healthMultiplierView = 0.01
		end
		UiText(string.format("%.0f%s (%.2f)", 100*healthMultiplierView, "%", healthMultiplierView))
		UiTranslate(-140, 0)
		
		-- Healing Speed
		UiAlign("left middle")
		UiTranslate(-32, 32)
		UiTranslate(-128, 32)
		UiTranslate(-300, 0)
		UiText("Healing speed")
		UiTranslate(300, 0)
		UiColor(1,1,1)
		UiTranslate(-300, 32)
		UiAlign("center middle")
		healingSpeed = UiSlider("ui/common/dot.png", "x", healingSpeed, 0, 600)
		healingSpeedView = healingSpeed/60000
		healingSpeedView = math.floor(healingSpeedView*10000+0.5)/10000
		UiTranslate(300, 0)
		UiRect(600, 4)
		UiAlign("right middle")
		UiTranslate(300, -32)
		UiText(string.format("%i%s  (%.4f)", (100/16)*healingSpeedView*10000, "%", healingSpeedView))
		UiTranslate(-300, 0)
		UiTranslate(160, 0)
		
		-- Healing Timeout
		UiAlign("left middle")
		UiTranslate(-32, 32)
		UiTranslate(-128, 32)
		UiTranslate(-300, 0)
		UiText("Timeout before being healed")
		UiTranslate(300, 0)
		UiColor(1,1,1)
		UiTranslate(-300, 32)
		UiAlign("center middle")
		healingTimeout = UiSlider("ui/common/dot.png", "x", healingTimeout, 0, 600)
		healingTimeoutView = healingTimeout--/1
		healingTimeoutView = math.floor(healingTimeoutView+0.5)
		UiTranslate(300, 0)
		UiRect(600, 4)
		UiAlign("right middle")
		UiTranslate(300, -32)
		--UiText(healingTimeoutView)
		UiText(string.format("%.2f %s  (%.0f frames)", math.floor((healingTimeoutView/6)*10)/100, "sec", healingTimeoutView))
		--UiTranslate(96, 0)
		--UiText(math.floor(healingTimeoutView/6+0.5)/10)
		--UiTranslate(32, 0)
		--UiText("Seconds")
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
			godmode = "false"
			screenEffectRed = "true"
			godmodeKey = "G"
			
			-- New features
			screenEffectBlur = "true"
			godmodeEnabledDefault = "false"
			godmodeHideText = "false"
			
		end
		
		-- Save
		UiTranslate(-256, 0)
		if UiTextButton("Save & close", 200, 40) then
			saveSettings()
			
			Menu()
		end
	
		-- Close
		UiTranslate(-256, 0)
		if UiTextButton("Discard & close", 200, 40) then
			Menu()
		end
	UiPop()
	
	
	-- Draw Health bar
	--drawHealthBar()
	
	
	
end

function loadSettings()

	local updateSettingsFile = false

	-- Enable godmode by default
	godmodeEnabledDefault = GetString("savegame.mod.godmodeEnabledDefault")
	if godmodeEnabledDefault == "" then 
		godmodeEnabledDefault = "false" 
		updateSettingsFile = true
	end
	-- Code - apply godmode settings
	if godmodeEnabledDefault == "true" then
		godmode = true
	end
	
	-- Fade away godmode text
	godmodeHideText = GetString("savegame.mod.godmodeHideText")
	if godmodeHideText == "" then 
		godmodeHideText = "false"
		updateSettingsFile = true
	end
	
	-- Toggle godmode key
	godmodeKey = GetString("savegame.mod.godmodeKey")
	if godmodeKey == "" or godmodeKey == nil then
		godmodeKey = "G"
		updateSettingsFile = true
	end
	
	
	
	-- Health bar always on screen
	alwaysShowHealthBar = GetInt("savegame.mod.alwaysShowHealthBar")
	if alwaysShowHealthBar < 1 then
		alwaysShowHealthBar = 1
		updateSettingsFile = true
	end
	
	-- Red screen on low health
	screenEffectRed = GetString("savegame.mod.screenEffectRed")
	if screenEffectRed == "" then
		screenEffectRed = "true" 
		updateSettingsFile = true
	end
	
	-- Screen blur on low health
	screenEffectBlur = GetString("savegame.mod.screenEffectBlur")
	if screenEffectBlur == "" then
		screenEffectBlur = "true"
		updateSettingsFile = true
	end

	-- Screen red on damage
	screenEffectDamage = GetString("savegame.mod.screenEffectDamage")
	if screenEffectDamage == "" then
		screenEffectDamage = "true"
		updateSettingsFile = true
	end


	
	
	-- Health multiplier
	healthMultiplier = GetInt("savegame.mod.healthMultiplier")
	
	-- Fixed bugged values
	if healthMultiplier == 6000 then
		healthMultiplier = 0
		updateSettingsFile = true
	end
	
	if healthMultiplier == nil or healthMultiplier == 0 then
		healthMultiplier = 1.0
	else 
		healthMultiplier = healthMultiplier/100 
	end
	healthMultiplier = healthMultiplier*60
	
	
	-- Healing speed
	healingSpeed = GetInt("savegame.mod.healingSpeed")
	-- Fixed bugged values
	if healingspeed == 600000 then
		healingspeed = 0
		updateSettingsFile = true
	end
	if healingSpeed == nil or healingSpeed == 0 then healingSpeed = 0.0016 else healingSpeed = healingSpeed/10000 end
	if GetInt("savegame.mod.healingSpeed") == 10000 then healingSpeed = 0 end
	--DebugPrint(healingSpeed)
	if healingSpeed > 0.01 then healingSpeed = 0.0016 end -- 0.01
	healingSpeed=healingSpeed*60000
	--DebugPrint(healingSpeed)
	--DebugPrint(0.0016*60000)
	
	
	
	
	-- Timeout before being healed
	healingTimeout = GetInt("savegame.mod.healingTimeout")
	if healingTimeout == nil or healingTimeout == 0 then healingTimeout = 0 end
	if GetInt("savegame.mod.healingTimeout") == 1000 then healingTimeout = 0 end
	--healingTimeout=healingTimeout
	
	
	
	-- Update settings if incomplete
	if updateSettingsFile == true then
		saveSettings()
	end
	
end

function saveSettings()

	SetString("savegame.mod.godmodeKey", godmodeKey)
	SetInt("savegame.mod.alwaysShowHealthBar", alwaysShowHealthBar)
	SetString("savegame.mod.screenEffectRed", screenEffectRed)
	if healthMultiplierView == 0 then healthMultiplierView = 1 end
	SetInt("savegame.mod.healthMultiplier", healthMultiplierView*100)
	if healingSpeedView == 0 then healingSpeedView = 1 end
	SetInt("savegame.mod.healingSpeed", healingSpeedView*10000)
	if healingTimeoutView == 0 then healingTimeoutView = 1000 end
	SetInt("savegame.mod.healingTimeout", healingTimeoutView)
	
	-- New features
	SetString("savegame.mod.screenEffectBlur", screenEffectBlur)
	SetString("savegame.mod.godmodeHideText", godmodeHideText)
	SetString("savegame.mod.godmodeEnabledDefault", godmodeEnabledDefault)

	SetString("savegame.mod.screenEffectDamage", screenEffectDamage)

end

function drawUiStatus(status)
	if status == true or status == "true" then
		UiText("Enabled")
		UiTranslate(-24, 0)
		UiColor(0,0.7,0)
		UiRect(22, 32)
		UiColor(1,1,1)
		UiTranslate(24, 0)
	else
		UiText("Disabled")
		UiTranslate(-24, 0)
		UiColor(0.7,0,0)
		UiRect(22, 32)
		UiColor(1,1,1)
		UiTranslate(24, 0)
	end
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
		if godmode == "true" then
			godmode = "false"
		else
			godmode = "true"
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