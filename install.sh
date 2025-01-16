#!/bin/bash

#
# install package
#
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
"arch")
    $SUDO pacman -S --noconfirm --needed base-devel git zsh vim tmux bat fd unzip lsd curl wget hexyl nodejs npm gist fzf python python-pip python-setuptools python-pipx python-pillow python-colorama bpython asciiquarium banner catimg cmatrix figlet jp2a letterpress nyancat toilet sl emacs screenfetch cowsay fortune-mod ponysay inetutils sysstat
    paru -S --needed --noconfirm gotop-bin ctree unimatrix-git pipes.sh arttime-git ascii-draw ascii-rain-git bash-pipes boxes cbonsai durdraw neo-matrix tty-clock mkinitcpio-archlogo alsi archey3 miniconda3
    pipx install bpytop numpy 
    $SUDO wget -d -c -O /usr/local/bin/ChristBASHTree "https://raw.githubusercontent.com/sergiolepore/ChristBASHTree/master/tree-EN.sh" 
    $SUDO chmod +x /usr/local/bin/ChristBASHTree 
    ;;
esac


#
# install tldr
#
$SUDO npm install -g --unsafe-perm tldr

#
# install oh-my-zsh
#
if [[ ! -d ~/.oh-my-zsh ]]; then
    wget -q -O install_ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    # CHSH=no RUNZSH=no sh install_ohmyzsh.sh
    sh install_ohmyzsh.sh --unattended
    rm install_ohmyzsh.sh
fi
# [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak
# cp _zshrc ~/.zshrc
# [[ ! -d ~/.oh-my-zsh/custom/themes/alien-minimal ]] && \
#     git clone -q --recurse-submodules https://github.com/eendroroy/alien-minimal.git \
#         ~/.oh-my-zsh/custom/themes/alien-minimal
[[ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]] && \
    git clone --depth=1 -q https://github.com/zsh-users/zsh-autosuggestions \
        ~/.oh-my-zsh/plugins/zsh-autosuggestions

# exec zsh -l
# $SUDO chsh -s $(which zsh)

# p10k theme
if [[ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
    git clone --depth=1 -q https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

#
# install rc files
#
for file_path in $(find $PWD -type f -name ".*" ); do 
    fname=$(basename $file_path)
    if ! [ "$fname" = ".zshrc" ] &&
       ! [ "$fname" = ".gdbinit" ] &&
       ! [ "$fname" = ".gitconfig" ]; then
        ln -sf $file_path $HOME/$fname; 
    fi
done
cat .gitconfig >> ~/.gitconfig
cat .zshrc >> ~/.zshrc

#
# tmux 2.x config
#
TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
if [[ "${TMUX_VERSION:0:1}" == "2" ]]; then
    sed -i 's/bind \\\\ split-window -h/bind \\ split-window -h/g' ~/.tmux.conf
fi

#
# install vim-plug
#
# if [[ ! -f ~/.vim/autoload/onedark.vim ]]; then
#     curl -sfLo ~/.vim/autoload/onedark.vim --create-dirs \
#         https://raw.githubusercontent.com/joshdick/onedark.vim/master/autoload/onedark.vim
# fi
# if [[ ! -f ~/.vim/colors/onedark.vim ]]; then
#     curl -sfLo ~/.vim/colors/onedark.vim --create-dirs \
#         https://raw.githubusercontent.com/joshdick/onedark.vim/master/colors/onedark.vim
# fi
if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
    curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugInstall +qall
    echo "colorscheme embark" >> ~/.vimrc
fi

#
# install miniconda
#
# if [[ ! -d ~/miniconda3 ]]; then
#     mkdir -p ~/miniconda3 
#     wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh 
#     bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 
#     rm ~/miniconda3/miniconda.sh 
# fi

#
# A curated list of command-line utilities written in Rust: 
#
# ref:
# https://gist.github.com/sts10/daadbc2f403bdffad1b6d33aff016c0a
# https://www.google.com/search?q=hyperfine+alternative&oq=hyperfine+alter&gs_lcrp=EgZjaHJvbWUqCAgBEAAYFhgeMgYIABBFGDkyCAgBEAAYFhgeMg0IAhAAGIYDGIAEGIoFMg0IAxAAGIYDGIAEGIoFMg0IBBAAGIYDGIAEGIoFMg0IBRAAGIYDGIAEGIoF0gEIMjI4MGowajSoAgCwAgE&sourceid=chrome&ie=UTF-8
#
# atuin: "Magical shell history"
# bandwhich: Terminal bandwidth utilization tool
# bat: A replacement for cat that provides syntax highlighting and other features.
# bottom: Yet another cross-platform graphical process/system monitor.
# broot: A new way to see and navigate directory trees
# counts: "A tool for ad hoc profiling"
# choose: A human-friendly and fast alternative to cut and (sometimes) awk
# delta: A syntax-highlighting pager for git, diff, and grep output
# difftastic: A syntax-aware diff
# dog: A command-line DNS client
# dua: "View disk space usage and delete unwanted data, fast."
# dust: "a more intuitive version of du in Rust"
# eza: "A modern version of ls".
# fclones: an "efficient duplicate file finder"
# fd: "A simple, fast and user-friendly alternative to find"
# felix: tui file manager with vim-like key mapping
# ffsend: "Easily and securely share files from the command line. A fully featured Firefox Send client."
# frum: A modern Ruby version manager written in Rust
# fselect: "Find files with SQL-like queries"
# git-cliff: "A highly customizable Changelog Generator that follows Conventional Commit specifications"
# gptman: "A GPT manager that allows you to copy partitions from one disk to another and more"
# grex: A command-line tool and library for generating regular expressions from user-provided test cases
# Himalaya: Command-line interface for email management
# htmlq: Like jq, but for HTML. Uses CSS selectors to extract bits of content from HTML files.
# hyperfine: Command-line benchmarking tool
# inlyne: "GPU powered yet browsless tool to help you quickly view markdown files"
# jless: "command-line JSON viewer designed for reading, exploring, and searching through JSON data."
# jql: A JSON query language CLI tool
# just: Just a command runner (seems like an alternative to make)
# legdur: A "simple CLI program to compute hashes of large sets of files in large directory structures and compare them with a previous snapshot."
# lemmeknow: Identify mysterious text or analyze hard-coded strings from captured network packets, malwares, and more.
# lfs: A Linux utility to get information on filesystems; like df but better
# lsd: The next generation ls command (though personally I prefer eza)
# macchina: Fast, minimal and customizable system information frontend.
# mdBook: Create books from markdown files. Like Gitbook but implemented in Rust
# mdcat: Fancy cat for Markdown
# miniserve is "a CLI tool to serve files and dirs over HTTP". I use this as a replacement for python -m SimpleHTTPServer, or whatever the latest version of that command is.
# monolith: Save complete web pages as a single HTML file
# ouch: "Painless compression and decompression for your terminal"
# pastel: A command-line tool to generate, analyze, convert and manipulate colors.
# pipr: "A tool to interactively write shell pipelines."
# procs: A modern replacement for ps written in Rust
# qsv: CSVs sliced, diced & analyzed. (A fork of xsv)
# rargs: xargs + awk with pattern matching support.
# rip: A safe and ergonomic alternative to rm
# ripgrep: A faster replacement for GNU’s grep command. This tool is very good. See ripgrep-all to search PDFs, E-Books, Office documents, zip, tar.gz, etc.
# ripsecrets: Find secret keys in your code before commiting them to git. I've contributed to this one!
# rnr: "A command-line tool to batch rename files and directories"
# sd: Intuitive find & replace CLI (sed alternative).
# skim: A command-line fuzzy finder.
# tealdear: A very fast implementation of tldr in Rust.
# teehee: "A modal terminal hex editor"
# tin-summer: Find build artifacts that are taking up disk space
# tokei: Count your (lines of) code, quickly
# topgrade: Upgrade all of your tools
# watchexec: Execute commands in response to file modifications. (Note: See cargo watch if you want to watch a Rust project.)
# xcp: An extended cp
# xh: "Friendly and fast tool for sending HTTP requests"
# xsv: A fast CSV command line toolkit written in Rust. (Last updated in 2018)
# zoxide: A smarter cd command.
