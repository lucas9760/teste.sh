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

# Função para iniciar o servidor e gerar o link da página HTML
start_server() {
    echo "Iniciando servidor..."
    
    # Inicie o servidor PHP para servir a página HTML
    php -S localhost:8080 &>/dev/null &

    # Use o Serveo para gerar o link da página HTML
    echo "Gerando link da página HTML..."
    local serveo_link="$(ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net 2>/dev/null | grep -oP 'https://[^\"]+')"
    
    if [ -z "$serveo_link" ]; then
        echo "Erro ao obter o link do Serveo."
    else
        echo "Página HTML disponível em: $serveo_link"
    fi
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
