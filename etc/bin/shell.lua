-- Run any programs passed in as arguments
local tArgs = { ... }
if #tArgs > 0 then
	shell.run( ... )
end
local function runLine( _sLine )
	local tWords = {}
	for match in string.gmatch( _sLine, "[^ \t]+" ) do
		table.insert( tWords, match )
	end

	local sCommand = tWords[1]
	if sCommand then
		return shell.run( sCommand, unpack( tWords, 2 ) )
	end
	return false
end
local function cprint( text )
	local x, y = term.getCursorPos()
	local a, _ = term.getSize()
	local s = string.len( text )
	term.setCursorPos(a/2-s/2, y)
	print( text )
end
local function header()
	term.setCursorPos(1, 1)
	term.setBackgroundColor( colors.orange )
	term.clearLine()
	term.setTextColor( colors.white )
	local user = "root"
	if USER_SYSTEM.UserName ~= nil then user = USER_SYSTEM.UserName end
	cprint("Console [" .. user .. "]")
end
-- Read commands and execute them
local tCommandHistory = {}
while true do
	local x,y  = term.getCursorPos()
	header()
	if y == 1 then term.setCursorPos(x, 2) else term.setCursorPos(x, y) end
	term.setBackgroundColor( colors.black )
	term.setTextColor( colors.yellow )

	local user = "localUser"
	if USER_SYSTEM.UserName ~= nil then user = USER_SYSTEM.UserName end
	local dir = shell.dir()
	local sDir = fs.combine("/", "/home/" .. user )
	if dir == sDir then dir = "#/" end
	if string.sub(dir, 1, string.len(sDir) ) == sDir then dir = "#/" .. string.sub(dir, string.len(sDir)+2) end

	write( dir .. "> " )
	term.setTextColor( colors.white )

	local sLine = read( nil, tCommandHistory )
	table.insert( tCommandHistory, sLine )
	runLine( sLine )
end
