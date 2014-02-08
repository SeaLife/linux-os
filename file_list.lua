-- Installer File-List
fs.makeDir("/etc/bin")
fs.makeDir("/etc/sbin")
fs.makeDir("/etc/usr")
fs.makeDir("/home/root")

INSTALL_FILES = {}

INSTALL_FILES[1] = "etc/bin/apt-get.lua"
INSTALL_FILES[2] = "etc/bin/shell.lua"
INSTALL_FILES[3] = "etc/bin/user.lua"
INSTALL_FILES[4] = "etc/bin/user_globals.lua"
