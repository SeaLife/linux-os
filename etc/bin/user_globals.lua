-- GLOBALS
if USER_SYSTEM ~= nil then return end
USER_SYSTEM = {}
USER_SYSTEM.UserList = {}
USER_SYSTEM.UserList[1] = "root:test"
USER_SYSTEM.UserName = ""
USER_SYSTEM.OldOsEvent = os.pullEvent
USER_SYSTEM.FileRestriction = {}
restrict = {}

if not fs.openBackup then fs.openBackup = fs.open end
if not fs.deleteBackup then fs.deleteBackup = fs.delete end
if not loadfileB then loadfileB = loadfile end
if not os.runB then os.runB = os.run end
if not os.pullEventB then os.pullEventB = os.pullEvent end
if not fs.moveB then fs.moveB = fs.move end

function os.run( _tEnv, _sPath, ... )
    local tArgs = { ... }
    local fnFile, err = loadfile( _sPath )
    if fnFile then
        local tEnv = _tEnv
        --setmetatable( tEnv, { __index = function(t,k) return _G[k] end } )
		setmetatable( tEnv, { __index = _G } )
        setfenv( fnFile, tEnv )
        local ok, err = pcall( function()
        	fnFile( unpack( tArgs ) )
        end )
        if not ok then
        	if err and err ~= "" then
	        	--printError( err )
	        end
        	return false
        end
        return true
    end
    if err and err ~= "" then
		--printError( err )
	end
    return false
end
loadfile = function( _sFile )
	local file = fs.open( _sFile, "r" )
	if file then
		local func, err = loadstring( file.readAll(), fs.getName( _sFile ) )
		file.close()
		return func, err
	end
	return nil, "Access Denied"
end

function fs.openD( string, mode )
	local file = fs.combine( shell.dir() , string)
	if USER_SYSTEM.FileRestriction[ USER_SYSTEM.UserName ] == nil then return fs.openBackup( string, mode ) end
	for k, v in pairs(USER_SYSTEM.FileRestriction[ USER_SYSTEM.UserName ]) do
		if file == v then
			error("Access Denied")
		end
	end
	return fs.openBackup( string, mode )
end
function fs.open(string, mode, isRestricted)
	local ok, err = pcall( fs.openD, string, mode )
	if ok == false then
		if shell.getRunningProgram() ~= "/etc/usr/list.lua" and isRestricted == nil then
			if term.isColor() == true then term.setTextColor( colors.orange ) end
			print("Access Denied!")
			term.setTextColor( colors.white )
		end
	else
		return err
	end
end
function fs.delete( string )
	local file = fs.combine( shell.dir() , string)
	if USER_SYSTEM.FileRestriction[ USER_SYSTEM.UserName ] == nil then return fs.deleteBackup( string ) end
	for k, v in pairs(USER_SYSTEM.FileRestriction[ USER_SYSTEM.UserName ]) do
		if fs.isDir( v ) == true and fs.combine("/", string) == fs.combine("/", v) then return nil end
		if file == v then
			return nil
		end
	end
	return fs.deleteBackup( string )
end
function fs.move( string, string2 )
	local file = fs.combine( shell.dir() , string2)
	if USER_SYSTEM.FileRestriction[ USER_SYSTEM.UserName ] == nil then return fs.moveB( string ) end
	for k, v in pairs(USER_SYSTEM.FileRestriction[ USER_SYSTEM.UserName ]) do
		if fs.isDir( v ) == true and fs.combine("/", string) == fs.combine("/", v) then
			if term.isColor() == true then term.setTextColor( colors.orange ) end
			print("Access Denied!")
			term.setTextColor( colors.white )
			return false
		end
		if file == v then
			if term.isColor() == true then term.setTextColor( colors.orange ) end
			print("Access Denied!")
			term.setTextColor( colors.white )
			return false
		end
	end
	return fs.moveB( string, string2 )
end

function restrict.createUser( user, pass )
	table.insert(USER_SYSTEM.UserList, user .. ":" .. pass )

	USER_SYSTEM.FileRestriction[ user ] = {}
end
function restrict.addResFile( user, file )
	if USER_SYSTEM.UserName == user then
		error("Cant restrict for yourself!")
		sleep(2)
	end
	if USER_SYSTEM.FileRestriction[ user ] == nil then
		error("User doesnt exists!")
		sleep(2)
	end
	if fs.exists( file ) == false then
		error("File does not exists!")
		sleep(2)
	end
	for k, v in pairs( USER_SYSTEM.FileRestriction[ user ] ) do
		if v == fs.combine("/", file ) then error("File is restricted!") end
	end
	table.insert( USER_SYSTEM.FileRestriction[ user ], fs.combine("/", file ) )
	for k, v in pairs( USER_SYSTEM.FileRestriction[ user ] ) do
		if v == fs.combine("/", file ) then return true end
	end
	return false
end
function restrict.remResFile( user, file )
	if USER_SYSTEM.UserName == user then
		error("Cant allow for yourself!")
		sleep(2)
	end
	if USER_SYSTEM.FileRestriction[ user ] == nil then
		error("User doesnt exists!")
		sleep(2)
	end
	if fs.exists( file ) == false and fs.isDir( file ) == false then
		error("File does not exists!")
		sleep(2)
	end
	local RemoveIndex = 0
	for k, v in pairs( USER_SYSTEM.FileRestriction[ user ] ) do
		if v == fs.combine("/", file ) then
			RemoveIndex = k
		end
	end
	if RemoveIndex ~= 0 then
		USER_SYSTEM.FileRestriction[ user ][ RemoveIndex ] = nil
		return true
	end
	return false
end

-- API Functions
function restrict.res( user, file)
	if restrict.addResFile(user, file) == false then
		error("File Restriction Failed!")
	end
	if term.isColor() == true then term.setTextColor( colors.red ) end
	print("[Restrict] " .. user .. " - " .. file)
	term.setTextColor( colors.white ) 
	sleep(0.1)
end
function restrict.resFolder( user, folder )
	local f = fs.list( folder )
	restrict.res( user, folder )
	for k,v in pairs( f ) do
		restrict.res( user, folder .. v)
	end
end
function restrict.resAllow(user, file )
	if restrict.remResFile(user, file) == false then
		error("File Allowance Failed!")
	end
	if term.isColor() == true then term.setTextColor( colors.green ) end
	print("[Allowed] " .. user .. " - " .. file)
	term.setTextColor( colors.white ) 
	sleep(0.1)
end