# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added 2 files to the project structure:
# 1. ~/.user.zsh - for customizing the shell related hyde configurations
# 2. ~/.zshenv - for updating the zsh environment variables handled by HyDE // this will be modified across updates

#  Plugins 
# oh-my-zsh plugins are loaded  in ~/.hyde.zshrc file, see the file for more information

#  Aliases 

# Navegação
alias ..="cd .."             # Voltar um diretório
alias ...="cd ../.."          # Voltar dois diretórios
alias ~="cd ~"                # Ir para o diretório home
alias l="eza -lh"             # Listar arquivos de forma legível com eza
alias la="eza -lah"           # Listar arquivos, incluindo os ocultos, com eza
alias ll="eza -l"             # Listar arquivos no formato de coluna com eza
alias lt="eza -lt modified"            # Listar arquivos por data de modificação com eza
alias ltr="eza -ltr"          # Listar arquivos em ordem reversa de data com eza

# Diretórios de Trabalho
alias projects="cd ~/Documentos/dev"  # Diretório de projetos
alias docs="cd ~/Documentos"     # Diretório de documentos
alias pcodi="cd ~/Documentos/dev/pcod" # Diretorio do PlayCodify 
alias config="cd ~/.config"

# Sistema
alias reboot="sudo reboot"      # Rebootar o sistema
alias shutdown="sudo shutdown -h now" # Desligar o sistema
alias upgrade="sudo pacman -Syu" # Atualizar pacotes no Arch
alias pci="sudo pacman -S"
alias pcr="sudo pacman --remove"

# Performance
alias cleanup="sudo pacman -Rns $(pacman -Qdtq) && sudo pacman -Sc" # Limpar pacotes desnecessários no Arch

# Outros
alias c="clear"                # Limpar a tela
alias df="df -h"                 # Mostrar espaço disponível em disco de forma legível
alias du="du -sh"                # Mostrar tamanho de diretórios


#  This is your file 
# Add your configurations here
# export EDITOR=nvim
export EDITOR=cursor

# unset -f command_not_found_handler # Uncomment to prevent searching for commands not found in package manager
