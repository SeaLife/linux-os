-- Installer File-List
fs.makeDir("/etc/bin")
fs.makeDir("/etc/sbin")
fs.makeDir("/etc/usr")
fs.makeDir("/startup.d")
fs.makeDir("/home/root")

INSTALL_FILES = {}

INSTALL_FILES[1] = "etc/bin/apt-get.lua"
INSTALL_FILES[2] = "etc/bin/shell.lua"
INSTALL_FILES[3] = "etc/bin/user.lua"
INSTALL_FILES[4] = "etc/bin/user_globals.lua"

INSTALL_FILES[5] = "etc/sbin/user"
INSTALL_FILES[6] = "etc/sbin/shell"
INSTALL_FILES[7] = "etc/sbin/apt-get"

INSTALL_FILES[7] = "etc/usr/list.lua"

INSTALL_FILES[9] = "startup"

INSTALL_FILES[10] = "startup.d/api_registry.lua"
INSTALL_FILES[11] = "startup.d/shell_aliases.lua"
INSTALL_FILES[12] = "startup.d/user_restrict.lua"

INSTALL_FILES[13] = ".repo"