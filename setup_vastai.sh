#!/usr/bin/env bash
# Fully patched bootstrap with maximal safe parallelization using curl --parallel
# - All comments in English
# - Save-then-run for all installer scripts (no pipes) to avoid curl error 23
# - Single apt txn; local .debs via apt install
# - Parallel artifact fetch: .deb/.tbz + plug.vim + oh-my-zsh + uv + micromamba
# - Headless vim-plug install (--sync)

set -Eeuo pipefail
trap 'echo "[!] Failed at line $LINENO: $BASH_COMMAND" >&2' ERR
export DEBIAN_FRONTEND=noninteractive

log(){ printf "[+] %s\n" "$*"; }
get_latest_tag(){ curl -fsSL "https://api.github.com/repos/$1/releases/latest" | grep -m1 '"tag_name"' | cut -d '"' -f 4; }

# 0) Base packages in a single transaction
log "Updating apt index & installing base packages..."
apt-get update -qq
apt-get -y -qq install git zsh vim tmux unzip curl wget fd-find bat time nvtop \
  python3.12-dev build-essential tree ca-certificates

# 1) Prepare workspace & resolve tags
WORK=/tmp/bootstrap
mkdir -p "$WORK" "$HOME/.vim/autoload" "$HOME/.oh-my-zsh"
OMZ_SH="$WORK/install_ohmyzsh.sh"
UV_SH="$WORK/install_uv.sh"
MM_TAR_DIR="$WORK/micromamba"
mkdir -p "$MM_TAR_DIR"

log "Resolving release tags (GitHub API)..."
HYPERFINE_TAG="$(get_latest_tag sharkdp/hyperfine)"
LSD_TAG="$(get_latest_tag lsd-rs/lsd)"
BTOP_TAG="$(get_latest_tag aristocratos/btop)"
GOTOP_TAG="$(get_latest_tag xxxserxxx/gotop)"

# Artifact URLs
HYPERFINE_DEB="https://github.com/sharkdp/hyperfine/releases/download/${HYPERFINE_TAG}/hyperfine_${HYPERFINE_TAG#v}_amd64.deb"
LSD_DEB="https://github.com/lsd-rs/lsd/releases/download/${LSD_TAG}/lsd-musl_${LSD_TAG#v}_amd64.deb"
BTOP_TBZ="https://github.com/aristocratos/btop/releases/download/${BTOP_TAG}/btop-x86_64-linux-musl.tbz"
GOTOP_DEB="https://github.com/xxxserxxx/gotop/releases/download/${GOTOP_TAG}/gotop_${GOTOP_TAG}_linux_amd64.deb"
PLUG_VIM_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
OMZ_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
UV_URL="https://astral.sh/uv/install.sh"
MM_URL="https://micro.mamba.pm/api/micromamba/linux-64/latest"

# 2) Parallel fetch of all artifacts & installer scripts
log "Parallel downloading artifacts & installer scripts..."
# Mix -O to WORK and -o to explicit paths. --output-dir applies to -O only.
curl --parallel --parallel-max 6 --create-dirs -fsS \
  --output-dir "$WORK" \
  -O "$HYPERFINE_DEB" \
  -O "$LSD_DEB" \
  -O "$BTOP_TBZ" \
  -O "$GOTOP_DEB" \
  -o "$HOME/.vim/autoload/plug.vim" "$PLUG_VIM_URL" \
  -o "$OMZ_SH" "$OMZ_URL" \
  -o "$UV_SH" "$UV_URL" \
  -o "$MM_TAR_DIR/micromamba.tar" "$MM_URL"

# 3) Local .deb install with apt (dependency-aware)
log "Installing local .deb packages via apt..."
apt-get -y -qq install \
  "$WORK"/hyperfine_*_amd64.deb \
  "$WORK"/lsd-musl_*_amd64.deb \
  "$WORK"/gotop_*_linux_amd64.deb

# 4) btop install (prebuilt tbz contains Makefile installer)
log "Installing btop..."
tar -xjf "$WORK"/btop-x86_64-linux-musl.tbz -C "$WORK"
make -C "$WORK"/btop -j"$(nproc)" install

# 5) uv install (save-then-run)
log "Installing uv..."
sh "$UV_SH"

# 6) oh-my-zsh (save-then-run, unattended)
log "Installing oh-my-zsh..."
sh "$OMZ_SH" --unattended || true

# 6.1) zsh plugins/themes (serial small ops)
if [ ! -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ]; then
  git clone --depth=1 -q https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"
fi
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM_DIR/themes"
if [ ! -d "$ZSH_CUSTOM_DIR/themes/powerlevel10k" ]; then
  git clone --depth=1 -q https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM_DIR/themes/powerlevel10k"
fi

# 7) micromamba install (save-then-run style)
log "Installing micromamba..."
# The API returns a tar stream; we saved it as micromamba.tar above
mkdir -p "$MM_TAR_DIR/extract"
tar -xvf "$MM_TAR_DIR/micromamba.tar" -C "$MM_TAR_DIR/extract" bin/micromamba
mkdir -p "$HOME/.local/bin"
mv "$MM_TAR_DIR/extract/bin/micromamba" "$HOME/.local/bin/micromamba"
rm -rf "$MM_TAR_DIR"

# Activate & init
if command -v "$HOME/.local/bin/micromamba" >/dev/null 2>&1; then
  eval "$("$HOME/.local/bin/micromamba" shell hook --shell bash)"
  "$HOME/.local/bin/micromamba" shell init -s zsh -r "$HOME/micromamba" || true
  "$HOME/.local/bin/micromamba" config append channels conda-forge || true
  "$HOME/.local/bin/micromamba" config set channel_priority strict || true
fi

# 8) dotfiles linking & appends
log "Linking dotfiles..."
for file_path in $(find "$PWD" -maxdepth 1 -type f -name ".*"); do
  fname="$(basename "$file_path")"
  if [[ "$fname" != ".zshrc" && "$fname" != ".gdbinit" && "$fname" != ".gitconfig" ]]; then
    ln -sf "$file_path" "$HOME/$fname"
  fi
done
: > "$HOME/.gitconfig"; cat "$PWD/.gitconfig" >> "$HOME/.gitconfig"
: > "$HOME/.zshrc";    cat "$PWD/.zshrc_vastai" >> "$HOME/.zshrc"
: > "$HOME/.p10k.zsh"; cat "$PWD/.p10k_vastai.zsh" >> "$HOME/.p10k.zsh"

# 9) tmux tweak for 2.x
if command -v tmux >/dev/null 2>&1; then
  TMUX_VERSION="$(tmux -V | awk '{print $2}')"
  if [[ "${TMUX_VERSION:0:1}" == "2" ]]; then
    sed -i 's/bind \\\\ split-window -h/bind \\ split-window -h/g' "$HOME/.tmux.conf" || true
  fi
fi

# 10) vim-plug plugin install
log "Running PlugInstall synchronously..."
vim +'PlugInstall --sync' +qall || true

# 11) locale
log "Setting locale to en_US.UTF-8..."
{
  echo 'LANG="en_US.UTF-8"'
  echo 'LC_ALL="en_US.UTF-8"'
} > /etc/default/locale || true

log "All done."
