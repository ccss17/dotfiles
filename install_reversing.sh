#!/bin/bash

set -xe
if [[ $UID == 0 ]]; then
    CMD=""
else
    CMD="sudo "
fi
distro=$(cat /etc/os-release | grep "^ID=" | cut -d\= -f2 | sed -e 's/"//g')
case "$distro" in
"ubuntu")
    $CMD dpkg --add-architecture i386
    $CMD apt-get -qq update
    $CMD apt-get -y -qq install gdb nasm radare2 libc6:i386 libncurses5:i386 libstdc++6:i386
    #$CMD apt-get install -y gdb radare2 multiarch-support
    if [[ ! -d ~/pwndbg ]]; then
        git clone -q https://github.com/pwndbg/pwndbg
        cd pwndbg
        ./setup.sh
        cd ..
        mv pwndbg ~
    fi
    # pwntools
    $CMD apt-get -y -qq install python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential
    python3 -m pip -q install --upgrade pip
    python3 -m pip -q install --upgrade git+https://github.com/Gallopsled/pwntools.git@dev
    # ropgadget
    python3 -m pip -q install capstone ropgadget
    ;;
"arch")
    $CMD pacman -S --noconfirm gdb pwndbg radare2 lib32-glibc ninja meson
    #pacman -S lib32-glibc lib32-ncurses lib32-libstdc++5
    ;;
esac

r2pm -U
$CMD r2pm -gi r2dec

[[ -f ~/.gdbinit ]] && mv ~/.gdbinit ~/.gdbinit.bak
cp .gdbinit ~/.gdbinit
if [[ -d /usr/share/pwndbg ]]; then
    sed -i "s/source ~\/pwndbg\/gdbinit.py/source \/usr\/share\/pwndbg\/gdbinit.py/g" ~/.gdbinit
fi