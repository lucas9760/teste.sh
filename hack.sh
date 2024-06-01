#!/bin/bash

# Verifica se o Termux está instalado
if [ ! -d "$PREFIX" ]; then
    echo "O Termux não parece estar instalado. Este script só funciona no Termux."
    exit 1
fi

# Função para verificar e instalar ferramentas necessárias
check_dependencies() {
    echo "Verificando dependências..."
    local missing_dependencies=()

    # Verifica se o PHP está instalado
    if ! command -v php &> /dev/null; then
        missing_dependencies+=("php")
    fi

    # Verifica se o wget está instalado
    if ! command -v wget &> /dev/null; then
        missing_dependencies+=("wget")
    fi

    # Verifica se o ngrok está instalado
    if [ ! -e "$HOME/ngrok" ]; then
        echo "Instalando Ngrok..."
        install_ngrok
    fi

    # Verifica se o unzip está instalado
    if ! command -v unzip &> /dev/null; then
        missing_dependencies+=("unzip")
    fi

    # Verifica se o jq está instalado
    if ! command -v jq &> /dev/null; then
        missing_dependencies+=("jq")
    fi

    # Instala as ferramentas ausentes
    if [ ${#missing_dependencies[@]} -gt 0 ]; then
        echo "Instalando ferramentas necessárias: ${missing_dependencies[*]}"
        pkg install -y "${missing_dependencies[@]}"
    fi
}

# Função para instalar o ngrok
install_ngrok() {
    # Verifica a arquitetura do sistema
    local arch=$(uname -m)
    local ngrok_url="https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip"

    # Baixa e extrai o ngrok
    echo "Baixando Ngrok..."
    wget -q -O ngrok.zip "$ngrok_url"
    unzip -o -q ngrok.zip
    rm ngrok.zip
    chmod +x ngrok
    mv ngrok "$HOME"

    echo "Ngrok instalado com sucesso!"
}

# Função para iniciar o servidor e gerar o link da página HTML
start_server() {
    echo "Iniciando servidor..."
    
    # Inicie o servidor PHP para servir a página HTML
    php -S localhost:8080 &>/dev/null &

    # Inicie o ngrok para gerar o link da página HTML
    echo "Gerando link da página HTML..."
    "$HOME/ngrok" http 8080 &>/dev/null &

    # Aguarde alguns segundos para que o ngrok gere o link
    sleep 10

    # Obtenha o link gerado pelo ngrok
    local page_link=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

    echo "Página HTML disponível em: $page_link"
}

# Função principal
main() {
    check_dependencies

    # Se todas as ferramentas estiverem instaladas, o script continua aqui
    echo "Todas as dependências estão instaladas. Continuando com o script..."

    # Inicie o servidor e gere o link da página HTML
    start_server
    
    # Adicione o restante do script aqui, se necessário
}

main "$@"
