
local tArgs = { ... }

-- Get all the files in the directory
local sDir = shell.dir()
if tArgs[1] ~= nil then
	sDir = shell.resolve( tArgs[1] )
end

-- Sort into dirs/files, and calculate column count
local tAll = fs.list( sDir )
local tFiles = {}
local tDirs = {}
local tResFiles = {}
local showRestricted = true
for n, sItem in pairs( tAll ) do
	if string.sub( sItem, 1, 1 ) ~= "." then
		local sPath = fs.combine( sDir, sItem )
		if fs.isDir( sPath ) then
			table.insert( tDirs, sItem )
		else
			local w = fs.open( sPath, "r", true)
			if w ~= nil then
				table.insert( tFiles, sItem )
				w.close()
			else
				table.insert( tResFiles, sItem )
			end
		end
	end
end
table.sort( tDirs )
table.sort( tFiles )
table.sort( tResFiles )

if showRestricted == true then
	if term.isColour() then
		textutils.pagedTabulate( colors.orange, tDirs, colors.green, tFiles, colors.red, tResFiles )
	else
		textutils.pagedTabulate( tDirs, tFiles, tResFiles )
	end
else
	if term.isColour() then
		textutils.pagedTabulate( colors.orange, tDirs, colors.green, tFiles)
	else
		textutils.pagedTabulate( tDirs, tFiles )
	end
end