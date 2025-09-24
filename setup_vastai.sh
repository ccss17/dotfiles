#!/usr/bin/env bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive  # zero prompts for apt
# 1) Single apt transaction (faster & atomic)
apt-get update -qq
apt-get -y -qq install \
  git zsh vim tmux unzip curl wget fd-find bat time nvtop python3.12-dev build-essential tree
# 참고: .deb는 dpkg 대신 apt로 설치하면 의존성 자동 해결됨: apt install ./pkg.deb  :contentReference[oaicite:3]{index=3}

# 2) Parallel downloads (curl --parallel). Install happens after downloads.
#    -Z/--parallel runs up to 50 transfers concurrently by default; cap via --parallel-max.
#    We fetch all release metadata first (fast), then artifacts in parallel.
get_latest_tag() {  # Fetch latest GitHub tag (no jq dependency)
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
  | grep -m1 '"tag_name"' | cut -d '"' -f 4
}

# Resolve versions (serial, tiny cost)
HYPERFINE_TAG="$(get_latest_tag sharkdp/hyperfine)"
LSD_TAG="$(get_latest_tag lsd-rs/lsd)"
BTOP_TAG="$(get_latest_tag aristocratos/btop)"
GOTOP_TAG="$(get_latest_tag xxxserxxx/gotop)"

# Build URL list and let curl fetch them in parallel
curl --parallel --parallel-max 4 -fsSLO \
  "https://github.com/sharkdp/hyperfine/releases/download/${HYPERFINE_TAG}/hyperfine_${HYPERFINE_TAG#v}_amd64.deb" \
  "https://github.com/lsd-rs/lsd/releases/download/${LSD_TAG}/lsd-musl_${LSD_TAG#v}_amd64.deb" \
  "https://github.com/aristocratos/btop/releases/download/${BTOP_TAG}/btop-x86_64-linux-musl.tbz" \
  "https://github.com/xxxserxxx/gotop/releases/download/${GOTOP_TAG}/gotop_${GOTOP_TAG}_linux_amd64.deb"
# curl의 --parallel/-Z: 다중 URL을 동시에 전송. 기본 50개 동시 처리, --parallel-max로 제한 가능. :contentReference[oaicite:4]{index=4}

# 3) Independent tasks: run in background and join with wait
(
  # uv installer (network I/O)
  curl -fsSL https://astral.sh/uv/install.sh | sh
) &

(
  # oh-my-zsh (network I/O)
  wget -q -O install_ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  sh install_ohmyzsh.sh --unattended
  rm install_ohmyzsh.sh
  git clone --depth=1 -q https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
  git clone --depth=1 -q https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
) &

wait  # downloads + background installs done

# 4) Local package installs (순차 권장: APT/DPKG는 락 때문에 병렬 설치 불가)
apt-get -y -qq install ./hyperfine_*_amd64.deb ./lsd-musl_*_amd64.deb ./gotop_*_linux_amd64.deb
# apt로 로컬 .deb 설치하면 의존성 자동 처리(dpkg -i보다 안전/편리). :contentReference[oaicite:5]{index=5}

# 5) btop build: parallel make
tar -xjf btop-x86_64-linux-musl.tbz
make -C btop -j"$(nproc)" install   # parallel jobs = CPU cores  :contentReference[oaicite:6]{index=6}

# 6) Dotfiles linking & appends (I/O 바운드 → xargs -P로 병렬 복사도 가능하지만 여기선 간단히 유지)
for file_path in $(find "$PWD" -maxdepth 1 -type f -name ".*"); do
  fname=$(basename "$file_path")
  if [[ "$fname" != ".zshrc" && "$fname" != ".gdbinit" && "$fname" != ".gitconfig" ]]; then
    ln -sf "$file_path" "$HOME/$fname"
  fi
done
cat .gitconfig >> ~/.gitconfig
cat .zshrc_vastai >> ~/.zshrc
cat .p10k_vastai.zsh >> ~/.p10k.zsh

# 7) tmux 2.x tweak (cheap check)
TMUX_VERSION=$(tmux -V | awk '{print $2}')
if [[ "${TMUX_VERSION:0:1}" == "2" ]]; then
  sed -i 's/bind \\\\ split-window -h/bind \\ split-window -h/g' ~/.tmux.conf
fi

# 8) vim-plug install (no prompt)
curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +'PlugInstall --sync' +qall  # blocks until done, no PRESS ENTER  (headless nvim even better)

# 9) locale
printf 'LANG="en_US.UTF-8"\nLC_ALL="en_US.UTF-8"\n' >/etc/default/locale
