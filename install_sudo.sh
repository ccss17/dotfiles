set -xe
if [[ $UID == 0 ]]; then
    SUDO=""
else
    SUDO="sudo "
fi
distro=$(cat /etc/os-release | grep "^ID=" | cut -d\= -f2 | sed -e 's/"//g')
case "$distro" in
"ubuntu" | "kali")
    # install git, zsh, vim, tmux
    $SUDO apt-get -y -qq install git zsh vim tmux unzip curl wget nodejs npm ruby-full python3 python3-pip bpython
    # install gist
    $SUDO gem install gist
    # install fd
    if ! type fd 2>/dev/null; then
        ZIPFILE="fd.deb"
        VERSION=`curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep tag_name | cut -d '"' -f 4`
        wget -q -O $ZIPFILE https://github.com/sharkdp/fd/releases/download/$VERSION/fd_${VERSION:1}_amd64.deb
        $SUDO dpkg -i $ZIPFILE
    fi
    # install bat
    if ! type bat 2>/dev/null; then
        DEBFILE="bat.deb"
        VERSION=`curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep tag_name | cut -d '"' -f 4`
        wget -q -O $DEBFILE https://github.com/sharkdp/bat/releases/download/$VERSION/bat_${VERSION:1}_amd64.deb
        $SUDO dpkg -i $DEBFILE
    fi
    if ! type lsd 2>/dev/null; then
        DEBFILE="lsd.deb"
        VERSION=`curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep tag_name | cut -d '"' -f 4`
        wget -q -O $DEBFILE https://github.com/lsd-rs/lsd/releases/download/$VERSION/lsd_${VERSION:1}_amd64.deb
        $SUDO dpkg -i $DEBFILE
    fi
    if ! type hexyl 2>/dev/null; then
        DEBFILE="hexyl.deb"
        VERSION=`curl -s https://api.github.com/repos/sharkdp/hexyl/releases/latest | grep tag_name | cut -d '"' -f 4`
        wget -O $DEBFILE https://github.com/sharkdp/hexyl/releases/download/$VERSION/hexyl_${VERSION:1}_amd64.deb
        $SUDO dpkg -i $DEBFILE
    fi
    if ! type fzf 2>/dev/null; then
        TGZFILE="fzf.tgz"
        VERSION=`curl -s https://api.github.com/repos/junegunn/fzf-bin/releases/latest | grep tag_name | cut -d '"' -f 4`
        wget -O $TGZFILE https://github.com/junegunn/fzf-bin/releases/download/$VERSION/fzf-${VERSION}-linux_amd64.tgz
        tar xf $TGZFILE
        $SUDO mv fzf /usr/local/bin/
    fi
    if ! type gotop 2>/dev/null; then
        git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
        /tmp/gotop/scripts/download.sh
        $SUDO mv gotop /usr/local/bin/
    fi
    $SUDO pip3 install bpytop --upgrade
    ;;
"arch" | "manjaro" | "endeavouros")
    $SUDO pacman -S --noconfirm --needed base-devel git zsh vim tmux bat fd unzip lsd curl wget hexyl nodejs npm gist fzf python python-pip python-setuptools python-pipx python-pillow python-colorama bpython asciiquarium banner catimg cmatrix figlet jp2a letterpress nyancat toilet sl emacs screenfetch cowsay fortune-mod ponysay inetutils sysstat alacritty ibus ibus-hangul discord ttf-firacode-nerd adobe-source-han-sans-kr-fonts adobe-source-han-serif-kr-fonts
    paru -S --needed --noconfirm gotop-bin ctree unimatrix-git pipes.sh arttime-git ascii-draw ascii-rain-git bash-pipes boxes cbonsai durdraw neo-matrix tty-clock mkinitcpio-archlogo alsi archey3 google-chrome visual-studio-code-bin ttf-nanum ttf-nanumgothic_coding kakaotalk
    pipx install bpytop numpy 
    $SUDO wget -d -c -O /usr/local/bin/ChristBASHTree "https://raw.githubusercontent.com/sergiolepore/ChristBASHTree/master/tree-EN.sh" 
    $SUDO chmod +x /usr/local/bin/ChristBASHTree 
    ;;
esac
