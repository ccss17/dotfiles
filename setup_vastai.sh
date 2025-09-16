#!/bin/bash
set -xe

apt-get -y -qq install git zsh vim tmux unzip curl wget nodejs npm ruby-full python3 python3-pip bpython fd-find bat hexyl fzf bpytop
if ! type hyperfine 2>/dev/null; then
    ZIPFILE="hyperfine.deb"
    VERSION=`curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest | grep tag_name | cut -d '"' -f 4`
    wget -q -O $ZIPFILE https://github.com/sharkdp/hyperfine/releases/download/$VERSION/hyperfine_${VERSION:1}_amd64.deb
    dpkg -i $ZIPFILE
fi

if ! type lsd 2>/dev/null; then
    ZIPFILE="lsd.deb"
    VERSION=`curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep tag_name | cut -d '"' -f 4`
    wget -q -O $ZIPFILE https://github.com/lsd-rs/lsd/releases/download/$VERSION/lsd-musl_${VERSION:1}_amd64.deb
    dpkg -i $ZIPFILE
fi

#
# install oh-my-zsh
#
if [[ ! -d ~/.oh-my-zsh ]]; then
    wget -q -O install_ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    # CHSH=no RUNZSH=no sh install_ohmyzsh.sh
    sh install_ohmyzsh.sh --unattended
    rm install_ohmyzsh.sh
fi


[[ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]] && \
    git clone --depth=1 -q https://github.com/zsh-users/zsh-autosuggestions \
        ~/.oh-my-zsh/plugins/zsh-autosuggestions

# p10k theme
if [[ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
    git clone --depth=1 -q https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

#
# uv
#
if ! type uv 2>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

#
# install micromamba
#
if [[ ! -d ~/micromamba ]]; then
    curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
    mkdir -p ~/.local/bin
    mv bin/micromamba ~/.local/bin/micromamba
    rmdir bin
    eval "$(~/.local/bin/micromamba shell hook --shell bash)"
    micromamba shell init -s zsh -r ~/micromamba
    micromamba config append channels conda-forge
    micromamba config set channel_priority strict
    micromamba activate
    micromamba install python -c conda-forge -y
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
cat .zshrc_vastai >> ~/.zshrc
cat .p10k_vastai >> ~/.p10k.zsh

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
if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
    curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugInstall +qall
    echo "colorscheme embark" >> ~/.vimrc
fi

