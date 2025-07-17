#!/bin/bash

# Cores para mensagens
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

detect_package_manager() {
  if command -v pacman &> /dev/null; then
    echo "pacman"
  elif command -v apt &> /dev/null; then
    echo "apt"
  elif command -v dnf &> /dev/null; then
    echo "dnf"
  else
    echo ""
  fi
}

check_install_packages() {
  local packages=("$@")
  local pm
  pm=$(detect_package_manager)

  if [ -z "$pm" ]; then
    echo -e "${RED}Gerenciador de pacotes não suportado ou não encontrado. Instale os pacotes manualmente.${RESET}"
    return 1
  fi

  local missing=()

  for pkg in "${packages[@]}"; do
    case "$pm" in
      pacman)
        if ! pacman -Qq "$pkg" &> /dev/null; then
          missing+=("$pkg")
        fi
        ;;
      apt)
        if ! dpkg -s "$pkg" &> /dev/null; then
          missing+=("$pkg")
        fi
        ;;
      dnf)
        if ! rpm -q "$pkg" &> /dev/null; then
          missing+=("$pkg")
        fi
        ;;
    esac
  done

  if [ ${#missing[@]} -eq 0 ]; then
    echo -e "${GREEN}Todos os pacotes necessários já estão instalados.${RESET}"
  else
    echo -e "${YELLOW}Instalando pacotes faltantes: ${missing[*]}${RESET}"

    case "$pm" in
      pacman)
        sudo pacman -S --needed "${missing[@]}"
        ;;
      apt)
        sudo apt update
        sudo apt install -y "${missing[@]}"
        ;;
      dnf)
        sudo dnf install -y "${missing[@]}"
        ;;
    esac
  fi
}

echo -e "${BLUE}🔧 Verificando pacotes essenciais...${RESET}"
check_install_packages git stow zsh i3-wm polybar rofi dunst kitty neovim fastfetch curl unzip wget

echo -e "${BLUE}📁 Aplicando dotfiles com GNU Stow...${RESET}"
cd "$(dirname "$0")" || exit 1

dotfiles=(i3 rofi polybar dunst kitty fastfetch nvim zsh starship)

for dir in "${dotfiles[@]}"; do
  target=$(stow -nv "$dir" 2>&1 | grep -oP '(?<=LINK: ).*')

  if [[ -n "$target" ]]; then
    for path in $target; do
      if [[ -e "$HOME/$path" && ! -L "$HOME/$path" ]]; then
        echo -e "${YELLOW}⚠️  Conflito detectado: $HOME/$path já existe como arquivo/pasta comum.${RESET}"
        read -rp "Deseja mover $HOME/$path para $HOME/${path}.backup e continuar? [s/N] " opt
        if [[ "$opt" =~ ^[sS]$ ]]; then
          mv "$HOME/$path" "$HOME/${path}.backup"
          echo -e "${GREEN}🔁 Movido para backup.${RESET}"
        else
          echo -e "${RED}⛔ Pulando $dir por conflito.${RESET}"
          continue 2
        fi
      fi
    done
  fi

  stow "$dir"
  echo -e "${GREEN}✅ $dir aplicado com sucesso.${RESET}"
done

echo -e "${BLUE}🌟 Instalando Oh My Zsh...${RESET}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo -e "${GREEN}✔️ Oh My Zsh instalado.${RESET}"
else
  echo -e "${YELLOW}Oh My Zsh já está instalado. Pulando...${RESET}"
fi

echo -e "${BLUE}🔌 Instalando plugins do Oh My Zsh...${RESET}"
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  echo -e "${GREEN}✔️ zsh-autosuggestions instalado.${RESET}"
else
  echo -e "${YELLOW}zsh-autosuggestions já existe.${RESET}"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  echo -e "${GREEN}✔️ zsh-syntax-highlighting instalado.${RESET}"
else
  echo -e "${YELLOW}zsh-syntax-highlighting já existe.${RESET}"
fi

if ! grep -q "plugins=.*zsh-autosuggestions" "$HOME/.zshrc"; then
  sed -i 's/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
  echo -e "${GREEN}⚙️ Plugins adicionados ao .zshrc.${RESET}"
fi

echo -e "${BLUE}🚀 Instalando Starship prompt...${RESET}"
if ! command -v starship &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  echo -e "${GREEN}✔️ Starship instalado.${RESET}"
else
  echo -e "${YELLOW}Starship já está instalado. Pulando...${RESET}"
fi

if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
  echo -e "\neval \"\$(starship init zsh)\"" >> "$HOME/.zshrc"
  echo -e "${GREEN}⭐ Starship adicionado ao .zshrc.${RESET}"
fi

echo -e "${BLUE}🔤 Instalando JetBrainsMono Nerd Font...${RESET}"
mkdir -p ~/.local/share/fonts
cd /tmp || exit 1
wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -qo JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
fc-cache -fv > /dev/null
echo -e "${GREEN}✔️ JetBrainsMono Nerd Font instalada.${RESET}"

echo -e "${BLUE}💬 Deseja tornar o Zsh o shell padrão?${RESET}"
read -rp "Mudar shell para Zsh agora? [s/N] " zsh_opt
if [[ "$zsh_opt" =~ ^[sS]$ ]]; then
  chsh -s "$(which zsh)"
  echo -e "${GREEN}✅ Shell alterado para Zsh. Relogue para aplicar.${RESET}"
else
  echo -e "${YELLOW}❗ Você pode mudar manualmente com: chsh -s \$(which zsh)${RESET}"
fi

echo -e "${BLUE}🎉 Instalação finalizada! Relogue ou reinicie a sessão para aplicar tudo.${RESET}"
