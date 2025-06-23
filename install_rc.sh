#!/bin/bash

set -xe
# [[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.bak
# cp _zshrc ~/.zshrc
# [[ ! -d ~/.oh-my-zsh/custom/themes/alien-minimal ]] && \
#     git clone -q --recurse-submodules https://github.com/eendroroy/alien-minimal.git \
#         ~/.oh-my-zsh/custom/themes/alien-minimal
# exec zsh -l
# $SUDO chsh -s $(which zsh)


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
