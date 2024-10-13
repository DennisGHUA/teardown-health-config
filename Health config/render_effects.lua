-- This adds the red screen effect
function renderEffectRed(modHealth, changeHealthDrain, lastTimePlayedIsDamaged, lastTimePlayedIsDamagedHealingRedScreen, lastTimePlayedIsDamagedHealthLost, damagePrecision, effectRed, effectDamage, effectDamageVignette)

    if modHealth >= 1 or GetPlayerHealth() <= 0 then
        return
    end

    -- Init red color alpha value
    local damageAlpha = 0

    local DamageColorRed = Vec(1, 0, 0)

    local realModHealth = modHealth * changeHealthDrain

    --
    --if effectDamage == false and realModHealth > 0.4 and modHealth > 0.8 then
    --    return
    --end


    -- Red screen on low health -- Vanilla version
    if effectRed then
    if realModHealth < 0.4 and modHealth < 0.8 then

    local alphaValue = 0.4-(realModHealth)
    if alphaValue > 0.4 then
    alphaValue = 0.4
    end

    damageAlpha = damageAlpha + alphaValue

    end
    end

    -- Red screen effect on taking damage
    if effectDamage then
    if lastTimePlayedIsDamaged < lastTimePlayedIsDamagedHealingRedScreen then -- 60 is 60 frames or 1 seconds

    local initAlphaValue = lastTimePlayedIsDamagedHealthLost / damagePrecision
    if initAlphaValue < 0.1 then initAlphaValue = 0.1 end

    local alphaValue = (initAlphaValue*((lastTimePlayedIsDamagedHealthLost/damagePrecision)+0.5)) * (1-(lastTimePlayedIsDamaged/lastTimePlayedIsDamagedHealingRedScreen))

    damageAlpha = damageAlpha + alphaValue

    end
    end


    -- Constrain alpha to max of 0.5
    if damageAlpha > 0.5 then damageAlpha = 0.5 end

    -- Give screen red color
    if effectDamageVignette == false then
    UiPush()
    UiColor(1,0,0, damageAlpha)
    UiRect(1920, 1080)
    UiPop()
    else
    damageAlpha = damageAlpha*2
    DrawDirectionalGradient(DamageColorRed, 1080/3, 1920, "down", damageAlpha, 0, 0)
    DrawDirectionalGradient(DamageColorRed, 1080/3, 1920, "up", damageAlpha, 0, 1080)
    DrawDirectionalGradient(DamageColorRed, 1080, 1920/3, "right", damageAlpha, 0, 0)
    DrawDirectionalGradient(DamageColorRed, 1080, 1920/3, "left", damageAlpha, 1920, 0)
    end

end



-- Function to draw a gradient from a solid color to transparent in a specified direction
function DrawDirectionalGradient(color, height, width, direction, startAlpha, x, y)
    UiPush()
    UiTranslate(x, y)  -- Translate to the specified position

    -- Loop to create the gradient effect based on the specified direction
    local steps = (direction == "left" or direction == "right") and width or height

    for i = 0, steps - 1 do
        local alpha = startAlpha - (i / (steps - 1) * startAlpha)  -- Calculate alpha from startAlpha to 0

        -- Ensure alpha does not go below 0
        alpha = math.max(0, alpha)

        UiColor(color[1], color[2], color[3], alpha)  -- Set the color with decreasing alpha

        if direction == "down" then
            UiRect(width, 1)      -- Draw a thin rectangle (1 pixel high, full width)
            UiTranslate(0, 1)     -- Move down for the next rectangle
        elseif direction == "up" then
            UiTranslate(0, -1)    -- Move up for the next rectangle
            UiRect(width, 1)      -- Draw a thin rectangle (1 pixel high, full width)
        elseif direction == "left" then
            UiTranslate(-1, 0)     -- Move left for the next rectangle
            UiRect(1, height)      -- Draw a thin rectangle (1 pixel wide, full height)
        elseif direction == "right" then
            UiRect(1, height)      -- Draw a thin rectangle (1 pixel wide, full height)
            UiTranslate(1, 0)      -- Move right for the next rectangle
        end
    end

    UiPop()
end







-- This adds the screen blur effect
function renderEffectBlur(modHealth, changeHealthDrain)
    --screenEffectBlur = true -- debug

    local realModHealth = modHealth * changeHealthDrain

    if realModHealth < 0.3 and modHealth < 0.6 then

        local alphaValue = 1.0-(realModHealth)

        UiPush()
        UiBlur(alphaValue)
        UiPop()

    elseif realModHealth < 0.4 and modHealth < 0.7 then

        local alphaValue = 0.7*(1-((realModHealth-0.3)*10))

        UiPush()
        UiBlur(alphaValue)
        UiPop()

    end

end