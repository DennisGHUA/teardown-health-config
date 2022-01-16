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
local godmodeButton = "G"
local respawnInstantly = false
local makeScreenRed = true

function init()
	-- Load config
	godmodeButton = GetString("savegame.mod.godmodeKey")
	if godmodeButton == "" or godmodeButton == nil then godmodeButton = "G" end
	
	alwaysShowHealthBar = GetInt("savegame.mod.alwaysShowHealthBar")
	if alwaysShowHealthBar < 1 then alwaysShowHealthBar = 1 end
	
	makeScreenRed = GetBool("savegame.mod.makeScreenRed")
	if makeScreenRed == nil then makeScreenRed = true end
	
	changeHealthDrain = GetInt("savegame.mod.healthMultiplier")
	--DebugPrint(changeHealthDrain)
	if changeHealthDrain == nil or changeHealthDrain == 0 then changeHealthDrain = 1.0 else changeHealthDrain = changeHealthDrain/100 end
	--DebugPrint(GetInt("savegame.mod.healthMultiplier"))
	
	healthGain = GetInt("savegame.mod.healingSpeed")
	if healthGain == nil or healthGain == 0 then healthGain = 0.0016 else healthGain = healthGain/10000 end
	if GetInt("savegame.mod.healingSpeed") == 10000 then healthGain = 0 end
	--DebugPrint(GetInt("savegame.mod.healingSpeed"))
	
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
end

--local testlastHealth = 0
function tick(dt)
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
			--DebugPrint("Healing")
			if modHealth > 0 and modHealth < 1 then
				modHealth = modHealth + (healthGain *(1.0/changeHealthDrain))
				if modHealth >= 1 then
					healthTimeout = healthGainTimeout
				end
			end
		end
	else
		-- Set godmode mode
		SetPlayerHealth(1)
	end
	
	-- Change godmode
	if InputReleased(godmodeButton) then
		if godmode == true then
			godmode = false
		else
			godmode = true
		end
	end
end


function update(dt)
	if godmode == false then 
	else
		-- Set godmode mode
		SetPlayerHealth(1)
	end
end

function draw(dt)

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
				--killPlayer()
				UiRect(104*modHealth, 16)
			UiPop()
		end
	else
		--- Set godmode mode
		SetPlayerHealth(1)
		
		UiPush()
			UiFont("bold.ttf", 24)
			UiTranslate(UiWidth()-22, UiHeight()-22)
			UiAlign("right")
			UiText("GODMODE")
		UiPop()
	end
	
	makeScreenRedFunction()
	
end


local revivePlayer = 10

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

function makeScreenRedFunction()

	if makeScreenRed == true and modHealth < 0.4 then
	
		local alphaValue = 0.4-(modHealth)
		if alphaValue > 0.4 then
			alphaValue = 0.4
		end
	
		UiPush()
			UiColor(1, 0, 0, alphaValue)
			UiRect(1920, 1080)
		UiPop()
	
	end

end