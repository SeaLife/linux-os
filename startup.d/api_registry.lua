registry = {}
REGISTRY_VERSION = "SeaTECH/8.1"
regDir = "/.registry/HKEY_LOCAL_MACHINE/"
function registry.isRegistered( progname )
	if fs.exists( regDir .. progname ) and fs.isDir( regDir .. progname ) then
		return true
	else
		return false
	end
end
function registry.register( progname )
	fs.makeDir( regDir .. progname )
end
function registry.unregister( progname )
	fs.delete( regDir .. progname )
end
function registry.writeData( progname, key, value )
	if registry.isRegistered( progname ) == true then
		local f = fs.open( regDir .. progname .. "/" .. key , "w" )
		f.write( value )
		f.close()
		return true
	else
		return false
	end
end
function registry.removeData( progname, key )
	if registry.isRegistered( progname ) == true then
		fs.delete( regDir .. progname .. "/" .. key)
		return true
	else
		return false
	end
end
function registry.getData( progname, key )
	if registry.isRegistered( progname ) == true then
		local f = fs.open( regDir .. progname .. "/" .. key , "r" )
		if f == nil then return false end
		
		local c = f.readAll()
		f.close()
		return c
	else
		return false
	end
end
function registry.dataExists( progname, key )
	if fs.exists( regDir .. progname .. "/" .. key ) then
		return true
	else
		return false
	end
end
