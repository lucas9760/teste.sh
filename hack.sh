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
        missing_dependencies+=("ngrok")
    fi

    # Verifica se o unzip está instalado
    if ! command -v unzip &> /dev/null; then
        missing_dependencies+=("unzip")
    fi

    # Instala as ferramentas ausentes
    if [ ${#missing_dependencies[@]} -gt 0 ]; then
        echo "Instalando ferramentas necessárias: ${missing_dependencies[*]}"
        pkg install -y "${missing_dependencies[@]}"
    fi
}

# Função para iniciar o servidor e gerar o link da página HTML
start_server() {
    echo "Iniciando servidor..."
    
    # Inicie o servidor PHP para servir a página HTML
    php -S localhost:8080 &>/dev/null &

    # Inicie o ngrok para gerar o link da página HTML
    echo "Gerando link da página HTML..."
    ./ngrok http 8080 &>/dev/null &

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
