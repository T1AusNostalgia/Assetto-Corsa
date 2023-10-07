local requiredSpeed = 45

local DriftPoints = 0
local DriftTracking = ac.getCarState(1)



function script.prepare(dt)
	
    return ac.getCarState(1).speedKmh > 60
end

local timePassed = 0
local speedMessageTimer = 0
local mackMessageTimer = 0

local driftTotal = 0
local driftPB = 0
local driftCombo = 1
local comboMeter = 1
local comboColor = 0
local dangerouslySlowTimer = 0
local carsState = {}
local wheelsWarningTimeout = 0

local mediaPlayer = ui.MediaPlayer()
local driftTickerSound = 'http' ..
    's://cdn.discordapp.com/attachments/140183723348852736/1010036237324779540/bong_001.ogg'


local uiCustomPos = vec2(0, 0)
local uiMoveMode = false
local lastUiMoveKeyState = false

local muteToggle = false
local lastMuteKeyState = false
local messageState = false


function script.update(dt)
	

    local uiMoveKeyState = ac.isKeyDown(ac.KeyIndex.B)
    if uiMoveKeyState and lastUiMoveKeyState ~= uiMoveKeyState then
        uiMoveMode = not uiMoveMode
        lastUiMoveKeyState = uiMoveKeyState
        if messageState then
            addMessage('UI Move mode Disabled', -1)
            messageState = false
        else
            addMessage('UI Move mode Enabled', -1)
            messageState = true
        end


    elseif not uiMoveKeyState then
        lastUiMoveKeyState = false
    end


    if ui.mouseClicked(ui.MouseButton.Left) then
        if uiMoveMode then
            uiCustomPos = ui.mousePos()
        end
    end


    local muteKeyState = ac.isKeyDown(ac.KeyIndex.M)
    if muteKeyState and lastMuteKeyState ~= muteKeyState then
        muteToggle = not muteToggle
        if messageState then
            addMessage('Sounds off', -1)
            messageState = false
        else
            addMessage('Sounds on', -1)
            messageState = true
        end

        lastMuteKeyState = muteKeyState
    elseif not muteKeyState then
        lastMuteKeyState = false

    end




    if DriftTracking.isDriftValid then
        driftCombo = ac.getCarState(1).driftComboCounter
        DriftPoints = math.floor(DriftPoints + DriftTracking.driftInstantPoints) / 10
        if muteToggle then
            mediaPlayer:setSource(driftTickerSound)
            mediaPlayer:setVolume(.05)
            mediaPlayer:setLooping(true)
            mediaPlayer:play()
        end

        if DriftTracking.collidedWith == 0 then
            driftCombo = 1
            mediaPlayer:pause():setCurrentTime(0)
        end
    end
    driftTotal = DriftPoints
    DriftPoints = driftTotal
    if not DriftTracking.isDriftValid then
        mediaPlayer:pause():setCurrentTime(0)
        if driftTotal > driftPB then
            driftPB = driftTotal
        end
        DriftPoints = 0
        driftTotal = 0
    end
    if not DriftTracking.isDriftValid then
        driftCombo = 1
    end


    if timePassed == 0 then
        addMessage(ac.getCarName(0), 0)
        addMessage('Made by Boon', 2)
        addMessage('CTRL + D to toggle UI', -1)
        -- addMessage('M to toggle sounds', -1)
        addMessage('Delete to re-orient car', -1)
    end




    local player = ac.getCarState(1)
    if player.engineLifeLeft < 1 then
        ac.console('Overtake score: ' .. totalScore)
        return
    end

    local playerPos = player.position
    local playerDir = ac.getCameraForward()
    if ac.isKeyDown(ac.KeyIndex.Delete) and player.speedKmh < 15 then
        physics.setCarPosition(0, playerPos, playerDir)

    end

    timePassed = timePassed + dt
    speedMessageTimer = speedMessageTimer + dt
    mackMessageTimer = mackMessageTimer + dt



    local comboFadingRate = 0.5 * math.lerp(1, 0.1, math.lerpInvSat(player.speedKmh, 80, 200)) + player.wheelsOutside
    -- driftCombo = math.max(1, driftCombo - dt * comboFadingRate)

    local sim = ac.getSim()
    while sim.carsCount > #carsState do
        carsState[#carsState + 1] = {}
    end

    if wheelsWarningTimeout > 0 then
        wheelsWarningTimeout = wheelsWarningTimeout - dt
    elseif player.wheelsOutside > 0 then
        if wheelsWarningTimeout == 0 then
        end
        addMessage('Car is Out Of Zone', -1)
        DriftPoints = 0
        wheelsWarningTimeout = 60
    end

    if player.speedKmh < requiredSpeed then

        if dangerouslySlowTimer > 3 then
            -- ac.console('Overtake score: ' .. totalScore)
            DriftPoints = 0
            driftTotal = 0
        else
            if dangerouslySlowTimer < 3 then
                if speedMessageTimer > 5 and not timePassed == 0 then
                    addMessage('3 Seconds until score reset!', -1)
                    speedMessageTimer = 0
                end
            end

            if dangerouslySlowTimer == 0 and not timePassed == 0 then
                addMessage('Speed up!', -1)
            end

        end
        dangerouslySlowTimer = dangerouslySlowTimer + dt
        driftCombo = 1

        if player.wheelsOutside < 1 then
            if driftTotal > driftPB then
                driftPB = driftTotal
                ac.sendChatMessage('Drift: ' .. driftPB)
            end
        end


        return
    else
        dangerouslySlowTimer = 0
    end

    if player.collidedWith == 0 then

        if driftTotal >= driftPB then
            driftPB = driftTotal
            ac.sendChatMessage(' Drift: ' .. driftPB)
        end

        driftCombo = 1
        DriftPoints = 0
        driftTotal = 0
    end


    for i = 2, ac.getSim().carsCount do
        local car = ac.getCarState(i)
        local state = carsState[i]
    end
end

local messages = {}
local glitter = {}
local glitterCount = 0

function addMessage(text, mood)
    for i = math.min(#messages + 1, 4), 2, -1 do
        messages[i] = messages[i - 1]
        messages[i].targetPos = i
    end
    messages[1] = { text = text, age = 0, targetPos = 1, currentPos = 1, mood = mood }
    if mood == 1 then
        for i = 1, 60 do
            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
            glitterCount = glitterCount + 1
            glitter[glitterCount] = {
                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
                pos = vec2(80, 140) + dir * vec2(40, 20),
                velocity = dir:normalize():scale(0.2 + math.random()),
                life = 0.5 + 0.5 * math.random()
            }
        end
    end
end

local function updateMessages(dt)
    comboColor = comboColor + dt * 10 * driftCombo
    if comboColor > 360 then comboColor = comboColor - 360 end
    for i = 1, #messages do
        local m = messages[i]
        m.age = m.age + dt
        m.currentPos = math.applyLag(m.currentPos, m.targetPos, 0.8, dt)
    end
    for i = glitterCount, 1, -1 do
        local g = glitter[i]
        g.pos:add(g.velocity)
        g.velocity.y = g.velocity.y + 0.02
        g.life = g.life - dt
        g.color.mult = math.saturate(g.life * 4)
        if g.life < 0 then
            if i < glitterCount then
                glitter[i] = glitter[glitterCount]
            end
            glitterCount = glitterCount - 1
        end
    end
    if driftCombo > 10 and math.random() > 0.98 then
        for i = 1, math.floor(driftCombo) do
            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
            glitterCount = glitterCount + 1
            glitter[glitterCount] = {
                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
                pos = vec2(195, 75) + dir * vec2(40, 20),
                velocity = dir:normalize():scale(0.2 + math.random()),
                life = 0.5 + 0.5 * math.random()
            }
        end
    end
end

local speedWarning = 0
local UIToggle = true
local LastKeyState = false
function script.drawUI()
    local keyState = ac.isKeyDown(ac.KeyIndex.Control) and ac.isKeyDown(ac.KeyIndex.D)
    if keyState and LastKeyState ~= keyState then
        UIToggle = not UIToggle
        LastKeyState = keyState
    elseif not keyState then
        LastKeyState = false
    end
    if UIToggle then
        local uiState = ac.getUiState()
        updateMessages(uiState.dt)

        local speedRelative = math.saturate(math.floor(ac.getCarState(1).speedKmh) / requiredSpeed)
        speedWarning = math.applyLag(speedWarning, speedRelative < 1 and 1 or 0, 0.5, uiState.dt)

        local colorDark = rgbm(0.4, 0.4, 0.4, 1)
        local colorGrey = rgbm(0.7, 0.7, 0.7, 1)
        local colorAccent = rgbm.new(hsv(speedRelative * 120, 1, 1):rgb(), 1)
        local colorCombo = rgbm.new(hsv(comboColor, math.saturate(driftCombo / 10), 1):rgb(),
            math.saturate(driftCombo / 4))

        local colorComboDrift = rgbm.new(hsv(comboColor, math.saturate(driftCombo / 10), 1):rgb(),
            math.saturate(driftCombo / 4))

        local function speedMeter(ref)
            ui.drawRectFilled(ref + vec2(0, -4), ref + vec2(180, 5), colorDark, 1)
            ui.drawLine(ref + vec2(0, -4), ref + vec2(0, 4), colorGrey, 1)
            ui.drawLine(ref + vec2(requiredSpeed, -4), ref + vec2(requiredSpeed, 4), colorGrey, 1)

            local speed = math.min(ac.getCarState(1).speedKmh, 180)
            if speed > 1 then
                ui.drawLine(ref + vec2(0, 0), ref + vec2(speed, 0), colorAccent, 4)
            end
        end

        ui.beginTransparentWindow('Drift', uiCustomPos, vec2(1400, 1400), true)
        ui.beginOutline()

        ui.pushStyleVar(ui.StyleVar.Alpha, 1)
        ui.pushFont(ui.Font.Title)
        ui.text('Shmoovin\' Drift')
        -- ui.sameLine(0, 20)
        ui.pushFont(ui.Font.Huge)
        ui.textColored('PB: ' .. driftPB .. ' pts', colorCombo)
        ui.popFont()
        ui.popStyleVar()

        ui.pushFont(ui.Font.Huge)
        ui.text(DriftPoints .. ' pts')
        ui.sameLine(0, 40)
        ui.beginRotation()
        ui.textColored(math.ceil(driftCombo * 10) / 10 .. 'x', colorComboDrift)

        -- if driftCombo > 5 then
        --     ui.endRotation(math.sin(driftCombo / 180 * 3141.5) * 3 * math.lerpInvSat(driftCombo, 20, 30) + 90)
        -- end
        -- if driftCombo > 10 then
        --     ui.endRotation(math.sin(driftCombo / 220 * 3141.5) * 3 * math.lerpInvSat(driftCombo, 20, 30) + 90)
        -- end
        -- if driftCombo > 20 then
        --     ui.endRotation(math.sin(driftCombo / 260 * 3141.5) * 3 * math.lerpInvSat(driftCombo, 20, 30) + 90)
        -- end
        -- if driftCombo > 50 then
        --     ui.endRotation(math.sin(driftCombo / 360 * 3141.5) * 3 * math.lerpInvSat(driftCombo, 20, 30) + 90)
        -- end

        ui.popFont()
        ui.endOutline(rgbm(0, 0, 0, 0.3))

        ui.offsetCursorY(20)
        ui.pushFont(ui.Font.Title)
        local startPos = ui.getCursor()
        for i = 1, #messages do
            local m = messages[i]
            local f = math.saturate(4 - m.currentPos) * math.saturate(8 - m.age)
            ui.setCursor(startPos + vec2(20 + math.saturate(1 - m.age * 10) ^ 2 * 100, (m.currentPos - 1) * 30))
            ui.textColored(m.text, m.mood == 1 and rgbm(0, 1, 0, f)
                or m.mood == -1 and rgbm(1, 0, 0, f) or m.mood == 2 and rgbm(100, 84, 0, f) or rgbm(1, 1, 1, f))
        end
        for i = 1, glitterCount do
            local g = glitter[i]
            if g ~= nil then
                ui.drawLine(g.pos, g.pos + g.velocity * 4, g.color, 2)
            end
        end
        ui.popFont()
        ui.setCursor(startPos + vec2(0, 4 * 30))

        ui.pushStyleVar(ui.StyleVar.Alpha, 1)
        ui.setCursorY(0)
        ui.pushFont(ui.Font.Main)
        -- ui.textColored('Keep speed above ' .. requiredSpeed .. ' km/h:', colorAccent)
        -- speedMeter(ui.getCursor() + vec2(-9, 4))
        ui.popFont()
        ui.popStyleVar()

        ui.endTransparentWindow()
    else
        ui.text('')

    end



end