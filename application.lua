
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
	domofon = function(value)
	    Player:playOpen(config.buzzerPin)
	    gpio.write(config.lockerPin, gpio.HIGH)
	    tmr.alarm(2, 5000, tmr.ALARM_SINGLE, function() 
	    	Player:playClose(config.buzzerPin)
	    	gpio.write(config.lockerPin, gpio.LOW)
	    end)
	    return 200,sjson.encode({action = "domofon", status = "open"})
	end
}

function handeRequest(conn, payload)
    local response = {
        code = nil,
        content = nil
    }
    local request = HttpParser.parse(payload)
    if (request.path == config.api_key) then
        if request.content then
            requestJson = sjson.decode(request.content)
            response["code"], response["content"] = Application.actions[requestJson.action](requestJson.value)
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
