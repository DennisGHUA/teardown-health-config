function drawHealthBar(modHealth, alwaysShowHealthBar, modHealthAdjusted)
    -- Draw HEALTH text
    if modHealth > 0 and modHealth < alwaysShowHealthBar then
        UiPush()
        -- Set correct color
        if modHealthAdjusted < 0.3 then
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

        --UiFont("bold.ttf", 32)
        --UiTranslate(0, -50)
        --UiAlign("middle")
        --UiText(math.ceil(modHealthAdjusted*100))

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
        if modHealthAdjusted < 0.3 then
            -- Red
            UiColor(1, 0, 0)
        elseif modHealthAdjusted < 0.8 then
            -- Yellow
            UiColor(1, 1, 1*modHealthAdjusted)
        end

        -- Die when out of health
        --killPlayer()
        UiRect(104*modHealth, 16)
        UiPop()
    end
end