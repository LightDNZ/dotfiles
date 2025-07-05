#!/usr/bin/env bash

# Early load to maintain fastfetch speed
if [ -z "${*}" ]; then
  clear
  exec fastfetch --logo-type kitty
  exit
fi

USAGE() {
  cat <<USAGE
Usage: fastfetch [commands] [options]

commands:
  logo    Display a random logo

options:
  -h, --help     Display command's help message

USAGE
}

# Diretórios e arquivos
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
logoDir="${confDir}/fastfetch/logo"
cacheDir="${HYDE_CACHE_HOME:-$HOME/.cache/hyde}"

# Arquivos de wallpaper (se existirem)
wallQuad="${cacheDir}/wall.quad"
wallSqre="${cacheDir}/wall.sqre"

# Função principal logo
case $1 in

logo)
  random() {
    (
      find "$logoDir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.icon" -o -iname "*logo*" \) 2>/dev/null
      [ -f "$wallQuad" ] && echo "$wallQuad"
      [ -f "$wallSqre" ] && echo "$wallSqre"
    ) | shuf -n 1
  }

  help() {
    cat <<HELP
Usage: ${0##*/} logo [option]

options:
  --quad    Use the current quad wallpaper
  --sqre    Use the current square wallpaper
  --rand    Pick a random logo (default)
  *help*    Show this help message

Note: Always includes logos from ~/.config/fastfetch/logo
HELP
  }

  shift
  # Sem argumentos → random
  [ -z "${*}" ] && random && exit
  [[ "$1" = "--rand" ]] && random && exit
  [[ "$1" = *"help"* ]] && help && exit

  (
    files=()
    for arg in "$@"; do
      case "$arg" in
        --quad)
          [ -f "$wallQuad" ] && files+=("$wallQuad")
          ;;
        --sqre)
          [ -f "$wallSqre" ] && files+=("$wallSqre")
          ;;
      esac
    done

    # Sempre adiciona as logos da pasta padrão
    logos=$(find "$logoDir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.icon" -o -iname "*logo*" \) 2>/dev/null)

    printf "%s\n" "${files[@]}"
    echo "$logos"
  ) | shuf -n 1
  ;;

help | --help | -h)
  USAGE
  ;;

*)
  clear
  exec fastfetch --logo-type kitty "$@"
  ;;
esac
