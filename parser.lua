-- Module declaration
local HttpParser = {}

local function isEmpty(s)
	return s == nil or s == ''
end

local function split(value, pattern)
	local outResults = { }
	local start = 1
	local splitStart, splitEnd = string.find( value, pattern, start )
	while splitStart do
	   table.insert( outResults, string.sub( value, start, splitStart-1 ) )
	   start = splitStart + 1
	   splitStart, splitEnd = string.find( value, pattern, start )
	end
	table.insert( outResults, string.sub( value, start ) )
	return outResults
end


function HttpParser.parse(payload)
	local request = {}
	local splitPayload = split(payload, "\r\n\r\n")
	local httpRequest = split((splitPayload[1]), "\r\n")
	if not isEmpty((splitPayload[2])) then 
	    request.content = (splitPayload[2])
	end
	
	local splitHeader = split((httpRequest[1]), "%s+")
	
	request.method = (splitHeader[1])
	request.path = string.sub((splitHeader[2]), 2)
	request.protocal = (splitHeader[3])
	    
	httpRequest = nil
	splitHeader = nil
	splitPayload = nil
	collectgarbage()

	return request
end

return HttpParser
