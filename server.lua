local Server = {
	http_code = {
		[200] = "200 OK",
		[401] = "401 Unauthorized"
	}
}

function Server:sendResponse(conn, code, content)
	if (self.http_code[code] ~= nil)
	then
		conn:send('HTTP/1.1 '.. self.http_code[code] ..'\r\nContent-Type: application/json\r\n\r\n '..content)
	end
end

function Server:start(receive)
	srv=net.createServer(net.TCP) 
	srv:listen(80,function(conn) 
	  conn:on("receive", receive)
	  conn:on("sent",function(conn) conn:close() end)
	end) 
end

return Server
