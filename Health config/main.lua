--This script will run on all levels when mod is active.
--Modding documentation: http://teardowngame.com/modding
--API reference: http://teardowngame.com/modding/api.html

-- Backend vars
local lastHealth = 1
local newHealth = 1
local modHealth = 1
local healthTimeout = 0
local godmode = false
local lastTimePlayedIsDamaged = 0
local damageTaken = 0
local newLastHealth = 0
local remainingDamage = 0


local damagePrecision = 100000000

local currentHealth = 1*damagePrecision
local lastHealth = 1*damagePrecision


-- Settings
local changeHealthDrain = 1.0
local healthGain = 0.0016
local healthGainTimeout = 0
local alwaysShowHealthBar = 1 -- 1 is false 2 is true
local godmodeKey = "G"
local respawnInstantly = "false"
local screenEffectRed = "true"

local screenEffectBlur = "true"
local godmodeEnabledDefault = "false"
local godmodeHideText = "false"
local godmodeTextFadeFrame = 120


function init()
	-- Load config
	--[[godmodeKey = GetString("savegame.mod.godmodeKey")
	if godmodeKey == "" or godmodeKey == nil then godmodeKey = "G" end]]--
	
	--[[alwaysShowHealthBar = GetInt("savegame.mod.alwaysShowHealthBar")
	if alwaysShowHealthBar < 1 then alwaysShowHealthBar = 1 end]]--
	
	--[[screenEffectRed = GetBool("savegame.mod.screenEffectRed")
	if screenEffectRed == nil then screenEffectRed = true end]]--
	
	changeHealthDrain = GetInt("savegame.mod.healthMultiplier")
	--DebugPrint(changeHealthDrain)
	if changeHealthDrain == nil or changeHealthDrain == 0 then changeHealthDrain = 1.0 else changeHealthDrain = changeHealthDrain/100 end
	--DebugPrint(GetInt("savegame.mod.healthMultiplier"))
	
	healthGain = GetInt("savegame.mod.healingSpeed")
	if healthGain == nil or healthGain == 0 then
		healthGain = 0.0016 
	else 
		healthGain = healthGain/10000 
	end
	if GetInt("savegame.mod.healingSpeed") == 10000 then healthGain = 0 end
	--DebugPrint(GetInt("savegame.mod.healingSpeed"))
	--DebugPrint(healthGain)
	
	healthGainTimeout = GetInt("savegame.mod.healingTimeout")
	if healthGainTimeout == nil or healthGainTimeout == 0 then healthGainTimeout = 0 end
	if GetInt("savegame.mod.healingTimeout") == 1000 then healthGainTimeout = 0 end
	
	if godmode == false then 
		-- Set health to 100%
		--SetPlayerHealth(1)
		
		-- Update lastHealth
		modHealth = 1
		lastHealth = 1*damagePrecision
		healthTimeout = healthGainTimeout
	end
	
	-- Load new features
	--screenEffectBlur = GetBool("savegame.mod.screenEffectBlur")
	--godmodeEnabledDefault = GetBool("savegame.mod.godmodeEnabledDefault")
	--godmodeHideText = GetBool("savegame.mod.godmodeHideText")
	--godmodeHideText = true
	
	-- Code
	--[[if godmodeEnabledDefault == true then
		godmode = true
	end]]--
	
	loadSettings()
	
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
	
	
	
	-- Health multiplier
	--[[healthMultiplier = GetInt("savegame.mod.healthMultiplier")
	if healthMultiplier == nil or healthMultiplier == 0 then
		healthMultiplier = 1.0
	else 
		healthMultiplier = healthMultiplier/100 
	end
	healthMultiplier = healthMultiplier*60]]--
	
	
	-- Healing speed
	--[[healingSpeed = GetInt("savegame.mod.healingSpeed")
	if healingSpeed == nil or healingSpeed == 0 then healingSpeed = 0.0016 else healingSpeed = healingSpeed/10000 end
	if GetInt("savegame.mod.healingSpeed") == 10000 then healingSpeed = 0 end
	healingSpeed=healingSpeed*60000]]--
	
	-- Timeout before being healed
	--[[healingTimeout = GetInt("savegame.mod.healingTimeout")
	if healingTimeout == nil or healingTimeout == 0 then healingTimeout = 0 end
	if GetInt("savegame.mod.healingTimeout") == 1000 then healingTimeout = 0 end
	healingTimeout=healingTimeout*2]]--
	
	
	
	-- Update settings if incomplete
	--[[if updateSettingsFile == true then
		--saveSettings()
	end]]--
	
end

--[[function saveSettings()

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
			
end]]--

--local testlastHealth = 0
-- Called exactly once per frame. The time step is variable but always between 0.0 and 0.0333333
function tick(dt)

	-- Change godmode
	if InputReleased(godmodeKey) then
		if godmode == true then
			godmode = false
			godmodeTextFadeFrame = 120 -- 2 sec
		else
			godmode = true
			-- Heal player and remove damage
			damageTaken = 0
			remainingDamage = 0
			modHealth = 1
			godmodeTextFadeFrame = 120 -- 2 sec
		end
	end

	if godmode == false then 
	else
		-- Set godmode mode
		SetPlayerHealth(1)
	end
end

-- Called at a fixed update rate, but at the most two times per frame. Time step is always 0.0166667 (60 updates per second). Depending on frame rate it might not be called at all for a particular frame.
function update(dt)
	--DebugPrint(modHealth)
	
	
	-- Fade godmode text
	if godmodeHideText == "true" and godmodeHideText == "true" then
		if godmodeTextFadeFrame > 0 then
			godmodeTextFadeFrame = godmodeTextFadeFrame - 1
		end
	end

	--[[if testlastHealth-GetPlayerHealth() < 0 then
		DebugPrint(testlastHealth-GetPlayerHealth())
	end
	testlastHealth = GetPlayerHealth()]]--

	if godmode == false then
	
		-- Kill player if health is below 0
		killPlayer()
		
		-- Healing timeout
		if modHealth < 1 and healthTimeout > 0 then
			healthTimeout = healthTimeout - 1
		elseif lastTimePlayedIsDamaged > 10 and remainingDamage <= 0 and damageTaken <= 0 then
			-- Heal player
			if modHealth > 0 and modHealth < 1 then
				--DebugPrint("Healing")
				modHealth = modHealth + (healthGain *(1.0/changeHealthDrain))
				--DebugPrint((healthGain *(1.0/changeHealthDrain)))
				if modHealth >= 1 then
					healthTimeout = healthGainTimeout
					modHealth = 1
				end
			end
		end
	else
		-- Set godmode mode
		SetPlayerHealth(1)
		
	end
	
	
end

function draw(dt)

	screenEffectRedFunction()
	
	if godmode == false then 

		-- Setup safe drawing area
		-- The drawing area is now 1920 by 1080 in the center of screen
		local x0, y0, x1, y1 = UiSafeMargins()
		UiTranslate(x0, y0)
		UiWindow(x1-x0, y1-y0, true)


		-- Get current health
		currentHealth = math.floor(GetPlayerHealth()*damagePrecision)
		
		-- Calculate damage
		--[[if currentHealth - lastHealth > 0 then
			DebugPrint(currentHealth - lastHealth)
		end]]--
		damageTaken = math.floor(math.floor(math.floor(currentHealth) - math.floor(lastHealth))) * - 1
		--DebugPrint(math.floor(currentHealth*100000))
		--DebugPrint(math.floor(lastHealth*100000))
		if damageTaken < 0 then -- Healing instead of taking damage
			damageTaken = 0
		end
		--[[if damageTaken > 0 then
			DebugPrint(damageTaken)
			DebugPrint(remainingDamage)
		end]]--
		--damageTaken = 0
		
		-- Update lastHealth
		if GetPlayerHealth() > 0 then -- This line prevents low health after dieing
			newLastHealth = GetPlayerHealth()*damagePrecision
		end
		
		-- Calculate damage
		if damageTaken > 0 then
			lastTimePlayedIsDamaged = 0
			--DebugPrint(changeHealthDrain)
			modHealth = modHealth - (math.floor((damageTaken * (1/changeHealthDrain)) + math.floor(remainingDamage * (1/changeHealthDrain)))/damagePrecision)
			--DebugPrint(currentHealth - lastHealth)
		else
			if lastTimePlayedIsDamaged < 100 then
				lastTimePlayedIsDamaged = lastTimePlayedIsDamaged + 1
			end
		end
		--[[if lastTimePlayedIsDamaged > 2 then
			DebugPrint(lastTimePlayedIsDamaged)
		end]]--
		
		
		if GetPlayerHealth() > 0 then -- This line prevents low health after dieing
			lastHealth = newLastHealth
		end
		
		
		-- Never show real health bar
		if modHealth > 0 and GetPlayerHealth() > 0 then
			remainingDamage=math.floor(damagePrecision-(math.floor(GetPlayerHealth()*damagePrecision)+math.floor(damageTaken))) -- positive value
			SetPlayerHealth(1)
			--remainingDamage = math.abs(remainingDamage)
			if remainingDamage < 0 then -- Healing instead of taking damage
				remainingDamage = 0
			end
			
			--[[if damageTaken < 0 or damageTaken > 0 or remainingDamage < 0 or remainingDamage > 0 then
				DebugPrint("damageTaken")
				DebugPrint(damageTaken/damagePrecision)
				DebugPrint("remainingDamage")
				DebugPrint(remainingDamage/damagePrecision)
			end]]--
			
			damageTaken = 0
		end
		
		local realModHealth = modHealth * changeHealthDrain
		
		-- Draw HEALTH text
		if modHealth > 0 and modHealth < alwaysShowHealthBar then 
			UiPush()
				-- Set correct color
				if realModHealth < 0.3 then
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
				if realModHealth < 0.3 then
					-- Red
					UiColor(1, 0, 0)
				elseif realModHealth < 0.8 then
					-- Yellow
					UiColor(1, 1, 1*realModHealth)
				end
				
				-- Die when out of health
				--killPlayer()
				UiRect(104*modHealth, 16)
			UiPop()
		end
		
		-- Draw godmode fade away
		if godmodeTextFadeFrame > 0 and godmodeHideText == "true" then
			UiPush()
				UiFont("bold.ttf", 24)
				UiTranslate(UiWidth()-22, UiHeight()-22)
				UiAlign("right")
				-- Fade GODMODE text
				if godmodeTextFadeFrame < 60 then
					UiColor(1,1,1,(1/60)*godmodeTextFadeFrame)
				end
				if modHealth < 1 or alwaysShowHealthBar == 2 then
					UiTranslate(0, -32) -- Move health text up when health bar is visible
				end
				UiText("GODMODE DISABLED")
			UiPop()
		end
		
	else
		--- Set godmode mode
		SetPlayerHealth(1)
		
		if godmodeTextFadeFrame > 0 then
			UiPush()
				UiFont("bold.ttf", 24)
				UiTranslate(UiWidth()-22, UiHeight()-22)
				UiAlign("right")
				-- Fade GODMODE text
				if godmodeTextFadeFrame < 60 then
					UiColor(1,1,1,(1/60)*godmodeTextFadeFrame)
				end
				if godmodeHideText == "true" then
					UiText("GODMODE ENABLED")
				else
					UiText("GODMODE")
				end
			UiPop()
		end
	end
	
	
end


local revivePlayer = 10 -- frames

function killPlayer()
	-- Make sure the player dies
	if modHealth < 0 then
		-- Kill player
		SetPlayerHealth(0)
		modHealth = -1
		
		-- Prevent visual glitch
		remainingDamage = 0
		damageTaken = 0

		-- Heal it when dead
		if modHealth <= 0 and revivePlayer > 0 then
			revivePlayer = revivePlayer - 1
		else
			revivePlayer = 60
			modHealth = 1
			lastHealth = 1
		end
		
	end
end

function screenEffectRedFunction()

	local realModHealth = modHealth * changeHealthDrain
	if screenEffectRed == "true" and realModHealth < 0.4 then
	
		local alphaValue = 0.4-(realModHealth)
		if alphaValue > 0.4 then
			alphaValue = 0.4
		end
	
		UiPush()
			UiColor(1, 0, 0, alphaValue)
			UiRect(1920, 1080)
		UiPop()
	
	end

	makescreenEffectBlurFunction()

end

function makescreenEffectBlurFunction()
	--screenEffectBlur = true -- debug

	local realModHealth = modHealth * changeHealthDrain

	if screenEffectBlur == "true" and realModHealth < 0.3 then
	
		local alphaValue = 1.0-(realModHealth)
	
		UiPush()
			UiBlur(alphaValue)
		UiPop()
	
	elseif screenEffectBlur == "true" and realModHealth < 0.4 then
	
		local alphaValue = 0.7*(1-((realModHealth-0.3)*10))
	
		UiPush()
			UiBlur(alphaValue)
		UiPop()
	
	end

end