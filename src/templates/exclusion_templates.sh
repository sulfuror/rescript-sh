# ============================================================== #
#                      EXCLUSION TEMPLATES                       #
# ============================================================== #

simple_exclusions() {
cat <<EOF
# These are the default rescript exclusions:
$HOME/.cache/*
$HOME/.local/share/Trash/*
$HOME/.rescript/lock/*
$HOME/.Trash
$HOME/.Private
$HOME/.ecryptfs

# Write your custom exclusions below:
EOF
}
long_exclusions() {
cat <<EOF
# These are the default rescript exclusions for your home directory:
$HOME/.cache/*
$HOME/.local/share/Trash/*
$HOME/.rescript/lock/*
$HOME/.gvfs
$HOME/.dbus
$HOME/.local/share/gvfs-metadata
$HOME/.Private
$HOME/.Trash
$HOME/.cddb
$HOME/.aptitude
$HOME/.adobe
$HOME/.bash_history
$HOME/.dropbox
$HOME/.dropbox-dist
$HOME/.macromedia
$HOME/.xsession-errors
$HOME/.recently-used
$HOME/.recently-used.xbel
$HOME/.local/share/recently-used*
$HOME/.thumbnails/*
$HOME/.Xauthority
$HOME/.ICEauthority
$HOME/.gksu.lock
$HOME/.pulse
$HOME/.pulse-cookie
$HOME/.esd_auth
$HOME/.ecryptfs
$HOME/.mozilla
$HOME/.config/google-chrome
$HOME/.config/chromium
$HOME/.opera
$HOME/.npm
$HOME/.gnupg/rnd
$HOME/.gnupg/random_seed
$HOME/.gnupg/.#*
$HOME/.gnupg/*.lock
$HOME/.gnupg/gpg-agent-info-*
$HOME/.config/**/Cache
$HOME/.config/**/GPUCache
$HOME/.config/**/ShaderCache
$HOME/snap/**/.config/**/Cache
$HOME/snap/**/.config/**/GPUCache
$HOME/snap/**/.config/**/ShaderCache
$HOME/Downloads
*.lock
*.bak
*.backup
*.backup*
*~

# Write your custom exclusions below:
EOF
}
sys_exclusions() {
cat <<EOF
# These are the default rescript exclusions for your system:
/home/*
/proc/*
/sys/*
/dev/*
/run/*
/mnt/*
/media/*
/etc/mtab
/var/cache/apt/archives/*.deb
lost+found/*
/tmp/*
/var/tmp/*
/var/backups/*

# Write your custom exclusions below:
EOF
}
