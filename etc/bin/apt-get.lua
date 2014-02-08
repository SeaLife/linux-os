-- Repository Functions


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
local function repoFile( file )
	if string.len( file ) > 20 then
		local f = fs.open("/tmp.1", "w")
		f.write( file )
		f.close()
		file = "/tmp.1"
	end
	local t = readLines( file )
	local isRepoFile = false
	local Table = {Name="Null", Version="0", Files="Null", Req="none", Autor="Null", Program="none", Startup="none"}
	for i=1, #t do
		if t[i] == "[Repo]" then isRepoFile = true end
		if string.sub( t[i], 1, 4) == "Name" and isRepoFile == true then 	Table.Name = string.sub( t[i], 6 ) end
		if string.sub( t[i], 1, 7) == "Version" and isRepoFile == true then Table.Version = string.sub( t[i], 9 ) end
		if string.sub( t[i], 1, 5) == "Files" and isRepoFile == true then 	Table.Files = string.sub( t[i], 7 ) end
		if string.sub( t[i], 1, 3) == "Req" and isRepoFile == true then 	Table.Req = string.sub( t[i], 5 ) end
		if string.sub( t[i], 1, 5) == "Autor" and isRepoFile == true then 	Table.Autor = string.sub( t[i], 7 ) end
		if string.sub( t[i], 1, 7) == "Program" and isRepoFile == true then 	Table.Program = string.sub( t[i], 9 ) end
		if string.sub( t[i], 1, 7) == "Startup" and isRepoFile == true then 	Table.Startup = string.sub( t[i], 9 ) end
	end
	fs.delete( "/tmp.1" )
	return Table
end
local function split(string, sep)
    local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	string:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
local function hasValue( table, value )
	for k, v in pairs( table ) do
		if v == value then return true end
	end
	return false
end

local REPOS = {}
local REPO_FILE = "/.repo"
local args = { ... }
local PROG_NAME = "Linux_PList"
if fs.exists("/.repo") == false then
	local f = fs.open( REPO_FILE, "w" )
	f.writeLine("http://localhost/cc-repo1/")
	f.close()
end
if fs.exists("/etc/sbin") == false then fs.makeDir("/etc/sbin") end
if fs.exists("/etc/bin") == false then fs.makeDir("/etc/bin") end
if registry.isRegistered( PROG_NAME ) == false then registry.register( PROG_NAME ) end

REPOS = readLines( REPO_FILE )

if args[1] == nil then args[1] = "help" end

if args[1] == "help" then
	print(" ")
	print(" Usage: ["..shell.getRunningProgram().." <Option>]")
	print(" ")
	print(" Options: ")
	print("  install  [package]")
	print("  update   [package]")
	print("  info     [package]")
	print("  remove   [package]")
	print("  add-repo [link]")
	print("  rem-repo [link]")
	print("  list")
	print(" ")
end
if args[1] == "add-repo" and args[2] ~= nil then
	if http.get( args[2] .. "packages.list.lua") ~= nil then
		if hasValue( REPOS, args[2] ) == false then
			local f = fs.open( REPO_FILE, "a")
			f.writeLine( args[2] )
			f.close()
			print(" Added Repo: " .. args[2])
			print(" ")
			shell.run( shell.getRunningProgram(), "list" )
		else
			print(" Repo allready exists!")
			print(" ")
		end
	else
		print(" Repository is broken!")
		print(" ")
	end
end
if args[1] == "rem-repo" and args[2] ~= nil then
	if hasValue( REPOS, args[2] ) == true then
		local r = ""
		for k, v in pairs( REPOS ) do
			if v == args[2] then r = k end
		end
		REPOS[r] = nil
		local f = fs.open(REPO_FILE, "w")

		for k, v in pairs( REPOS ) do
			f.writeLine( v )
		end
		f.close()
		shell.run( shell.getRunningProgram(), "list" )
	else
		print(" Repo does not exists in system!")
		print(" ")
	end
end
if args[1] == "info" and args[2] ~= nil then
	print(" >> Info :: " .. args[2] .. " << ")
	print(" ")
	print(" Fetching Repos . . .")
	sleep(1)
	local INFO = {}
	for i=1, #REPOS do
		local g = http.get( REPOS[i] .. args[2] .. ".repo.lua")
		if g then
			INFO.Repo = REPOS[i]
			INFO.Package = args[2] .. ".repo.lua"
			INFO.Content = g.readAll()
			g.close()
			break
		end
	end
	if INFO.Repo ~= nil then
		print(" Info '" .. args[2] .. "':")
		print(" ")
		local packageInfo = repoFile( INFO.Content )
		packageInfo.Files = split( packageInfo.Files, ",")
		print(" Repositorie:  " .. INFO.Repo )
		print(" Version:      " .. packageInfo.Version )
		print(" Author:       " .. packageInfo.Autor )
		print(" Files:        " .. #packageInfo.Files )
		print(" Requirements: " .. packageInfo.Req )
	else
		print(" ")
		print("No package '" .. args[2] .. "' available!")
	end
end

if args[1] == "list" then
	--print("[List] All available packages")
	for i=1, #REPOS do
		print(" Fetching [" .. REPOS[ i ] .. "]" )
		local g = http.get( REPOS[ i ] .. "packages.list.lua" )
		if not g then 
			print(" [No Packages]")
		else
			local f = fs.open("/tmp.1", "w")
			f.write( g.readAll() )
			f.close()
			local t = readLines( "/tmp.1" )
			fs.delete("/tmp.1")
			for k, v in pairs( t ) do
				print("  " .. k .. ": " .. v)
			end
		end
		print(" ")
	end
end
if args[1] == "regPrograms" then
	local fileList = fs.list("/etc/sbin")

	for i=1, #fileList do
		shell.setAlias( fileList[i], "/etc/bin/" .. fileList[i] .. ".lua" )
		print("[Add Program]: " .. fileList[i] .. " to [" .. "/etc/bin/" .. fileList[i] .. "]")
	end
end
if args[1] == "install" and args[2] ~= nil then
	print(" >> Installing :: " .. args[2] .. " << ")
	print(" ")
	print(" Fetching Repos . . .")
	sleep(1)
	local INFO = {}
	for i=1, #REPOS do
		local g = http.get( REPOS[i] .. args[2] .. ".repo.lua")
		if g then
			INFO.Repo = REPOS[i]
			INFO.Package = args[2] .. ".repo.lua"
			INFO.Content = g.readAll()
			g.close()
			break
		end
	end
	if INFO.Repo ~= nil then
		print(" Installing '" .. args[2] .. "':")
		print(" ")
		local packageInfo = repoFile( INFO.Content )
		packageInfo.Files = split( packageInfo.Files, ",")
		print(" Repositorie:  " .. INFO.Repo )
		print(" Version:      " .. packageInfo.Version )
		print(" Author:       " .. packageInfo.Autor )
		print(" Files:        " .. #packageInfo.Files )
		print(" Requirements: " .. packageInfo.Req )
		print(" Program:      " .. packageInfo.Program )
		print(" ")
		local yesno = ""
		while true do
			write(" Do you want to install this?: [Y/N]: ")
			yesno = read()
			if yesno == "y" or yesno == "Y" then yesno = "y" break end
			if yesno == "n" or yesno == "N" then yesno = "n" break end
		end
		if yesno == "y" then

			for i=1, #packageInfo.Files do
				registry.writeData( PROG_NAME, args[2] .. "_c", i )
				registry.writeData( PROG_NAME, args[2] .. "_" .. i, packageInfo.Files[i] )

				local g = http.get( INFO.Repo .. args[2] .. "/" .. packageInfo.Files[i] )
				if not g then
					print(" [Error] " .. packageInfo.Files[i] .. " does not exists")
				else
					print(" [Downloading] " .. packageInfo.Files[i] )

					local f = fs.open( "/etc/bin/" .. packageInfo.Files[i], "w" )
					f.write( g.readAll() )
					f.close()

					if string.lower(packageInfo.Program) == "yes" and packageInfo.Files[i] ~= packageInfo.Startup then
						registry.writeData( PROG_NAME, args[2] .. "_s", string.sub(packageInfo.Files[i], 1, -5) )
						local f = fs.open("/etc/sbin/" .. string.sub(packageInfo.Files[i], 1, -5), "w" )
						f.write("shell.run('/etc/bin/" .. packageInfo.Files[i] .. "')")
						f.close()
					end
				end
			end
			if string.lower(packageInfo.Program) == "yes" then
				shell.run( shell.getRunningProgram(), "regPrograms" )
			end
		else
			print(" Aborted...")
		end
	else
		print(" ")
		print("No package '" .. args[2] .. "' available!")
	end
end
if args[1] == "remove" and args[2] ~= nil then
	if registry.dataExists( PROG_NAME, args[2] .. "_c" ) == false then
		print(" >> Package :: " .. args[2] .. " << ")
		print(" ")
		print(" [Not Found]")
	else
		print(" >> Package :: " .. args[2] .. " << ")
		print(" ")
		print(" Found: " .. tonumber(registry.getData(PROG_NAME, args[2] .. "_c")) )
		print(" ")
		for i=1, tonumber(registry.getData(PROG_NAME, args[2] .. "_c")) do
			print(" Removing [" .. registry.getData(PROG_NAME, args[2] .. "_" .. i) .. "]" )
		end
		print(" ")
		write(" Do you really want to remove them? [Y/N]: ")
		local r = read()
		if string.lower(r) == "y" then
			for i=1, tonumber(registry.getData(PROG_NAME, args[2] .. "_c")) do
				fs.delete( "/etc/bin/" .. registry.getData(PROG_NAME, args[2] .. "_" .. i) )
				print(" [Deleting]: /etc/bin/" .. registry.getData(PROG_NAME, args[2] .. "_" .. i) )
				registry.removeData( PROG_NAME, args[2] .. "_" .. i )
			end
			registry.removeData( PROG_NAME,  args[2] .. "_c") 
			if registry.dataExists( PROG_NAME, args[2] .. "_s") then
				fs.delete("/etc/sbin/" .. registry.getData(PROG_NAME, args[2] .. "_s") )
				print(" [Deleting]: /etc/sbin/" .. registry.getData(PROG_NAME, args[2] .. "_s") )
				shell.clearAlias(registry.getData(PROG_NAME, args[2] .. "_s"))
				registry.removeData(PROG_NAME, args[2] .. "_s")
			end
		else
			print(" ")
			print(" Aborted...")
		end
	end
end