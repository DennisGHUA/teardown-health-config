--This script will run on all levels when mod is active.
--Modding documentation: http://teardowngame.com/modding
--API reference: http://teardowngame.com/modding/api.html

#include "mod_settings.lua"
#include "render_health.lua"
#include "render_effects.lua"

-- Backend vars
local lastHealth = 1
local newHealth = 1
local modHealth = 1
local healthTimeout = 0
local godmode = false
local lastTimePlayedIsDamaged = 300
local lastTimePlayedIsDamagedHealthLost = 0
local lastTimePlayedIsDamagedHealingRedScreen = 120
local damageTaken = 0
local newLastHealth = 0
local remainingDamage = 0

-- Multiplay and substract damage value by this to avoid float calculation errors
local damagePrecision = 100000000 --100.000.000

local currentHealth = 1*damagePrecision
local lastHealth = 1*damagePrecision


-- Settings
local changeHealthDrain = 1.0
local healingSpeed = 0.0016 -- healthGain
local healthGainTimeout = 0
local alwaysShowHealthBar = 1 -- 1 is false 2 is true
local godmodeKey = "G"
local respawnInstantly = "false"
local screenEffectRed = "true"
local screenEffectDamage = "true"

local screenEffectBlur = "true"
local godmodeEnabledDefault = "false"
local godmodeHideText = "false"
local godmodeTextFadeFrame = 120


local killPlayerRunning = false
local ThreadHaltToKillPlayer = false

function init()

	-- disable regeneration for player
	SetPlayerRegenerationState(false)

	changeHealthDrain = GetInt("savegame.mod.healthMultiplier")
	-- Fixed bugged values
	if changeHealthDrain == 6000 then
		changeHealthDrain = 0
		--updateSettingsFile = true
	end
	--DebugPrint(changeHealthDrain)
	if changeHealthDrain == nil or changeHealthDrain == 0 then changeHealthDrain = 1.0 else changeHealthDrain = changeHealthDrain/100 end
	--DebugPrint(GetInt("savegame.mod.healthMultiplier"))

	healingSpeed = GetInt("savegame.mod.healingSpeed")
	-- Fixed bugged values
	if healingSpeed == 600000 then
		healingSpeed = 0
		--updateSettingsFile = true
	end
	if healingSpeed == nil or healingSpeed == 0 or healingSpeed > 0.01 then
		healingSpeed = 0.0016
	else
		healingSpeed = healingSpeed/10000
	end
	if GetInt("savegame.mod.healingSpeed") == 10000 then healingSpeed = 0 end

	
	healthGainTimeout = GetInt("savegame.mod.healingTimeout")
	if healthGainTimeout == nil or healthGainTimeout <= 0 or healthGainTimeout > 601 then
		healthGainTimeout = 0
	else
		healthGainTimeout = healthGainTimeout/0.16666
		healthGainTimeout = math.floor(healthGainTimeout+0.5)
	end
	--if GetInt("savegame.mod.healingTimeout") == 1000 then healthGainTimeout = 0 end
	
	if godmode == false then 
		-- Set health to 100%
		--SetPlayerHealth(1)
		
		-- Update lastHealth
		modHealth = 1
		lastHealth = 1*damagePrecision
		healthTimeout = healthGainTimeout
	end

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

	-- Screen red on damage
	screenEffectDamage = GetString("savegame.mod.screenEffectDamage")
	if screenEffectDamage == "" then
		screenEffectDamage = "true"
		updateSettingsFile = true
	end
	
end

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
			lastTimePlayedIsDamaged = 300
			lastTimePlayedIsDamagedHealthLost = 0
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
	--DebugPrint(GetPlayerHealth())
	--DebugPrint(modHealth)
	--if killPlayerRunning then
	--	DebugPrint("T")
	--else
	--	DebugPrint("F")
	--end
	--DebugPrint(healthTimeout)

	if modHealth < 0 then
		modHealth = -1
	end

	if killPlayerRunning == true then
		-- Heal it when dead
		if GetPlayerHealth() > 0 then
			--DebugPrint("Healing")
			revivePlayer = 60
			modHealth = 1
			lastHealth = 1
			killPlayerRunning = false
			ThreadHaltToKillPlayer = false
		end
	end
	
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
				modHealth = modHealth + (healingSpeed *(1.0/changeHealthDrain))
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

	-- Setup safe drawing area
	-- The drawing area is now 1920 by 1080 in the center of screen
	local x0, y0, x1, y1 = UiSafeMargins()
	UiTranslate(x0, y0)
	UiWindow(x1-x0, y1-y0, true)

	-- Render effects if godmode is disabled
	if godmode == false then


		-- Render red screen effect if enabled
		if screenEffectRed == "true" then
			renderEffectRed(modHealth, changeHealthDrain, lastTimePlayedIsDamaged, lastTimePlayedIsDamagedHealingRedScreen, lastTimePlayedIsDamagedHealthLost, damagePrecision)
		end

		-- Render blur screen effect if enabled
		if screenEffectRed == "true" then
			renderEffectBlur(modHealth, changeHealthDrain)
		end



		-- Get current health
		currentHealth = math.floor(GetPlayerHealth()*damagePrecision)
		
		-- Calculate damage
		damageTaken = math.floor(math.floor(math.floor(currentHealth) - math.floor(lastHealth))) * - 1

		if damageTaken < 0 then -- Healing instead of taking damage
			damageTaken = 0
		end
		
		-- Update lastHealth
		if GetPlayerHealth() > 0 then -- This line prevents low health after dieing
			newLastHealth = GetPlayerHealth()*damagePrecision
		end
		
		-- Calculate damage
		if damageTaken > 0 then
			if lastTimePlayedIsDamaged > lastTimePlayedIsDamagedHealingRedScreen or damageTaken > lastTimePlayedIsDamagedHealthLost then
				lastTimePlayedIsDamagedHealthLost = damageTaken
			end
			lastTimePlayedIsDamaged = 0
			--DebugPrint(changeHealthDrain)
			modHealth = modHealth - (math.floor((damageTaken * (1/changeHealthDrain)) + math.floor(remainingDamage * (1/changeHealthDrain)))/damagePrecision)
			if modHealth <= 0 then
				ThreadHaltToKillPlayer = true
			end
			--DebugPrint(currentHealth - lastHealth)
			healthTimeout = healthGainTimeout
		else
			if lastTimePlayedIsDamaged < 300 then
				lastTimePlayedIsDamaged = lastTimePlayedIsDamaged + 1
			end
		end
		--[[if lastTimePlayedIsDamaged > 2 then
			DebugPrint(lastTimePlayedIsDamaged)
		end]]--
		
		
		if GetPlayerHealth() > 0 then -- This line prevents low health after dying
			lastHealth = newLastHealth
		end
		
		
		-- Never show real health bar
		if modHealth > 0 and GetPlayerHealth() > 0 then
			remainingDamage=math.floor(damagePrecision-(math.floor(GetPlayerHealth()*damagePrecision)+math.floor(damageTaken))) -- positive value
			if ThreadHaltToKillPlayer == false then
				if GetPlayerHealth() < 1 then
					--DebugPrint("Set health 1")
					SetPlayerHealth(1.0)
				end
			end
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
		
		local modHealthAdjusted = modHealth * changeHealthDrain
		
		-- Draw Health bar
		drawHealthBar(modHealth, alwaysShowHealthBar, modHealthAdjusted)
		
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


function killPlayer()
	if ThreadHaltToKillPlayer == false or killPlayerRunning == true then
		return
	end
	-- Make sure the player dies
	if modHealth <= 0 then
		killPlayerRunning = true

		-- Kill player
		modHealth = -1
		SetPlayerHealth(0)
		--MakeRagdoll(animator)

		-- Hacky workaround for the 1.6 update to trigger the ragdoll
		Shoot(VecAdd(GetPlayerPos(), Vec(0,3,0)), Vec(0, -1, 0), "bullet", 1, .01)


		damageTaken = 0
		remainingDamage = 0
		lastTimePlayedIsDamaged = 300
		lastTimePlayedIsDamagedHealthLost = 0

		-- Prevent visual glitch
		remainingDamage = 0
		damageTaken = 0
		
	end
end
