local Player = {
 tones = {},
}

Player.tones["aS"] = 880
Player.tones["cS"] = 523
Player.tones["eS"] = 659

local function beep(pin, tone, duration)
    pwm.setup(pin, Player.tones[tone], 512)
    pwm.start(pin)
    tmr.delay(duration * 1000)
    pwm.stop(pin)
    tmr.wdclr()
    tmr.delay(20000)
end

function Player:playOpen(pin)
    beep(pin, "cS", 100)
    beep(pin, "eS", 100)
    beep(pin, "aS", 100)
end

function Player:playClose(pin)
    beep(pin, "aS", 100)
    beep(pin, "eS", 100)
    beep(pin, "cS", 100)
end

return Player
