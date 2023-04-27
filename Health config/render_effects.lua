-- This adds the red screen effect
function renderEffectRed(modHealth, changeHealthDrain, lastTimePlayedIsDamaged, lastTimePlayedIsDamagedHealingRedScreen, lastTimePlayedIsDamagedHealthLost, damagePrecision)



    -- Init red color alpha value
    local damageAlpha = 0

    local realModHealth = modHealth * changeHealthDrain

    if realModHealth < 0.4 and modHealth < 0.8 then

        local alphaValue = 0.4-(realModHealth)
        if alphaValue > 0.4 then
            alphaValue = 0.4
        end

        damageAlpha = damageAlpha + alphaValue

        -- Red screen effect on taking damage
    elseif lastTimePlayedIsDamaged < lastTimePlayedIsDamagedHealingRedScreen then -- 60 is 60 frames or 1 seconds

        local initAlphaValue = lastTimePlayedIsDamagedHealthLost / damagePrecision
        if initAlphaValue < 0.1 then initAlphaValue = 0.1 end

        local alphaValue = (initAlphaValue*((lastTimePlayedIsDamagedHealthLost/damagePrecision)+0.5)) * (1-(lastTimePlayedIsDamaged/lastTimePlayedIsDamagedHealingRedScreen))

        damageAlpha = damageAlpha + alphaValue
    end

    -- Constrain alpha to max of 0.5
    if damageAlpha > 0.5 then damageAlpha = 0.5 end

    -- Give screen red color
    UiPush()
    UiColor(1, 0, 0, damageAlpha)
    UiRect(1920, 1080)
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