local u = restrict

u.createUser("sealife", "selina")

u.res("sealife", "/startup")
u.res("sealife", "/rom/programs/lua")
u.res("sealife", "/rom/programs/shell")
u.res("sealife", "/rom/programs/delete")

-- Restrict Folders

u.res("sealife", "/etc/")
u.resFolder("sealife", "/etc/bin/")
u.resFolder("sealife", "/etc/sbin/")
u.resFolder("sealife", "/startup.d/")

u.resAllow("sealife", "/etc/bin/user.lua")
u.resAllow("sealife", "/etc/bin/shell.lua")
