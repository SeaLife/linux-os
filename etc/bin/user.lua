local args = { ... }

-- Local Functions
local function readLines(sPath)
	local file = fs.open(sPath, "r")
	if file then
		local tLines = {}
		local sLine = file.readLine()
		while sLine do
			table.insert(tLines, sLine)
			sLine = file.readLine()
		end
		file.close()
		return tLines
	end
	return nil
end
local function split(string, sep)
    local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	string:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
local function cprint( text )
	local x, y = term.getCursorPos()
	local a, _ = term.getSize()
	local s = string.len( text )
	term.setCursorPos(a/2-s/2, y)
	print( text )
end
local function readFile( file )
	local f = fs.open( file, "r")
	local x = f.readAll()
	f.close()

	return x
end

-- System
if USER_SYSTEM.UserName ~= "" then
	if args[1] == "restrict" and args[2] ~= nil and args[3] ~= nil then
		restrict.addResFile( args[2], args[3] )
	end
	if args[1] == "logout" then
		USER_SYSTEM.UserName = ""
		shell.run( "user" )
	end
else
	while true do
		os.pullEvent = os.pullEventRaw
		shell.run("clear")
		term.setBackgroundColor( colors.white )
		term.setTextColor( colors.black )
		term.clearLine()
		cprint("SSH Terminal [localhost]")
		term.setBackgroundColor( colors.black )
		term.setTextColor( colors.white )
		print(" ")
		write("login as: ")
		local r = read()
		write( r .. "@localhost's password: ")
		local p = read("*")
		local login = false
		for k, v in pairs( USER_SYSTEM.UserList ) do
			if v == (r .. ":" .. p) then
				print(" ")
				print(" ")
				if term.isColor() == true then term.setTextColor( colors.orange ) end
				cprint("Login Successfully!")
				if term.isColor() == true then term.setTextColor( colors.white ) end
				USER_SYSTEM.UserName = r
				login = true

				if fs.exists("/home/" .. r ) == true and fs.isDir( "/home/" .. r ) == true then
					shell.run("cd", "/home/" .. r)
					if fs.exists("/home/" .. r .. "/startup.lua") == true then
						print(" ")
						print(" ")
						cprint("[Autorun]: startup.lua")
						shell.run("/home/" .. r .. "/startup.lua")
					end
				else
					shell.run("cd", "/")
				end
				break
			end
		end
		if login == true then break end
		if login == false then
			print(" ")
			print(" ")
			if term.isColor() == true then term.setTextColor( colors.red ) end
			cprint("Login Failed!")
			if term.isColor() == true then term.setTextColor( colors.white ) end
			sleep(2)
		end

	end
	term.setBackgroundColor( colors.black )
	term.setTextColor( colors.white )
	sleep(2)
	shell.run("clear")
	print("Logged in as [" .. USER_SYSTEM.UserName .. "]")
end
