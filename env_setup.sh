#!/bin/bash

echo "🔧 Configurando variáveis de ambiente do Hookinator..."

# Verificar se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo "❌ Arquivo .env não encontrado!"
    echo "📝 Crie um arquivo .env com as configurações necessárias"
    return 1
fi

# Ler e exportar cada linha do .env
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Pular linhas vazias e comentários
    if [[ -n "$key" && ! "$key" =~ ^[[:space:]]*# ]]; then
        # Remover espaços em branco
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Exportar a variável
        export "$key"="$value"
        echo "✅ $key definido"
    fi
done < .env

echo "🚀 Variáveis de ambiente configuradas!"
echo "💡 Agora você pode executar: dune exec hookinator.exe"