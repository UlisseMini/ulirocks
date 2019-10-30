#!/bin/bash
set -e

# Ask them for their chroot username and password
printf 'Username: '
read -r USERNAME
printf 'Password: '
read -r -s PASSWORD
echo

# used by crouton for setting the username
export USERNAME

cd ~/Downloads
curl -sSL https://goo.gl/fd3zc -o crouton

sudo -E bash crouton -n test -t xfce,cli-extra -r xenial < /dev/null

# User step: Download minecraft and make shortcut on desktop
sudo enter-chroot -u 0 -n test bash <<EOF
echo "$USERNAME:$PASSWORD" | chpasswd
mkdir -p "/home/$USERNAME/Downloads"
cd "/home/$USERNAME/Downloads" || exit 1
pwd
if ! [ -f Minecraft.deb ]; then
	sudo -u "#1000" wget https://launcher.mojang.com/download/Minecraft.deb
fi

dpkg -i Minecraft.deb; apt install -y -f

cat <<END > ../Desktop/minecraft-launcher.desktop
[Desktop Entry]
Type=Application
Version=1.0
Name=Minecraft Launcher
Comment=Official Minecraft Launcher
Exec=/opt/minecraft-launcher/minecraft-launcher
Path=/opt/minecraft-launcher
Icon=minecraft-launcher
Terminal=false
Categories=Game;Application;
END
chown "$USERNAME" ../Desktop/minecraft-launcher.desktop
chmod +x ../Desktop/minecraft-launcher.desktop
EOF
