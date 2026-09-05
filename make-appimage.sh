#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q protontricks | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/bcf6aa9582f676e1c93d0022319e6055cd1f2de2/Papirus/64x64/apps/wine.svg
export DESKTOP=/usr/share/applications/protontricks.desktop
export DEPLOY_PYTHON=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1

# Deploy dependencies
quick-sharun \
	/usr/bin/*tricks*        \
	/usr/bin/zenity          \
	/usr/bin/cabextract      \
	/usr/bin/aria2c          \
	/usr/bin/unzip           \
	/usr/bin/unrar           \
	/usr/bin/xz              \
	/usr/lib/7zip/7z*        \
	/usr/lib/libopenjp2.so*  \
	/usr/lib/libtiff.so*     \
	/usr/lib/libimagequant.so*

echo 'unset VK_DRIVER_FILES' >> ./AppDir/.env

cc -shared -fPIC -O2 -o ./AppDir/lib/execve-sharun-hack.so execve-sharun-hack.c -ldl
echo 'execve-sharun-hack.so' >> ./AppDir/.preload
echo 'export ANYLINUX_EXECVE_WRAP_PATHS="$DATADIR:$HOME/.steam"' >> ./AppDir/bin/execve-wrap-path.hook

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
