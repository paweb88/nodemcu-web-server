
local Player = require "player"
local Server = require "server"
local HttpParser = require "parser"
local LedRGB = require "led_rgb"

local Application = {}

local function setupGPIO()
	gpio.mode(config.buzzerPin, gpio.OUTPUT)
	gpio.mode(config.lockerPin, gpio.OUTPUT)
	gpio.mode(config.ledPin.red, gpio.OUTPUT)
	gpio.mode(config.ledPin.blue, gpio.OUTPUT)
	gpio.mode(config.ledPin.green, gpio.OUTPUT)

	gpio.write(config.lockerPin, gpio.LOW)
	gpio.write(config.ledPin.red, gpio.LOW)
	gpio.write(config.ledPin.blue, gpio.LOW)
	gpio.write(config.ledPin.green, gpio.LOW)
end

function Application:setup()
	setupGPIO()
	-- WIFI setup
	wifi.setmode(wifi.STATION)
	wifi.sta.config(config.wifi.ssid,config.wifi.password)
	wifi.sta.connect()

	LedRGB:setup(config.ledPin.red, config.ledPin.green, config.ledPin.blue)
	
	-- Turn red light to end setup
	LedRGB.lightRed()
end

Application.actions = {
	intercom = function(value)
		if (value == 'open')
		then
		    Player:playOpen(config.buzzerPin)
		    gpio.write(config.lockerPin, gpio.HIGH)
		    tmr.alarm(2, 5000, tmr.ALARM_SINGLE, function() 
		    	Player:playClose(config.buzzerPin)
		    	gpio.write(config.lockerPin, gpio.LOW)
		    end)
		    return 200,sjson.encode({action = "intercom", status = "open"})
		end
	end
}

function handeRequest(conn, payload)
    local response = {
        code = nil,
        content = nil
    }
    local request = HttpParser.parse(payload)
    if (request.path[2] == config.api_key) then
        if request.path[3] then
            local method = (request.path[3]);
            response["code"], response["content"] = Application.actions[method](request.path[4])
        end
    else
        response["code"] = 401
        response["content"] = sjson.encode({error = "Access denied"})
    end
    Server:sendResponse(conn, response.code, response.content)
end

function Application:start()
	tmr.alarm(1, 2000, tmr.ALARM_AUTO, function() 
	    if wifi.sta.getip()== nil then 
	    	LedRGB.lightBlue()
	    else 
	        tmr.stop(1)
	        print("Config done, IP is "..wifi.sta.getip())
	        LedRGB.lightGreen()
	        Server:start(handeRequest)
	    end 
	end)
end

return Application
