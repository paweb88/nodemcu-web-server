local LedRGB = {
	pins = {}
}

function LedRGB:setup(redPin, greenPin, bluePin)
	self.pins["red"] = redPin
	self.pins["green"] = greenPin
	self.pins["blue"] = bluePin
end

local function turnOn(color)
	gpio.write(LedRGB.pins[color], gpio.HIGH)
end

local function turnOff(color)
	gpio.write(LedRGB.pins[color], gpio.LOW)
end

local function change(red, green, blue)
	--red
	if (red == 1) then turnOn("red") end
	if (red == 0) then turnOff("red") end
	--green
	if (green == 1) then turnOn("green") end
	if (green == 0) then turnOff("green") end
	--
	if (blue == 1) then turnOn("blue") end
	if (blue == 0) then turnOff("blue") end
end

function LedRGB.lightRed()
	change(1,0,0)
end

function LedRGB.lightGreen()
	change(0,1,0)
end

function LedRGB.lightBlue()
	change(0,0,1)
end

return LedRGB
