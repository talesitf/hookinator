# Hookinator

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OCaml](https://img.shields.io/badge/OCaml-5.2+-orange.svg)](https://ocaml.org/)

Hookinator é um serviço de webhook robusto e eficiente escrito em OCaml. Ele recebe webhooks HTTP, processa transações de forma assíncrona e envia notificações, oferecendo uma solução completa para integração de sistemas via webhooks.

## ✨ Funcionalidades

- 🔄 **Processamento de Webhooks**: Recebe e processa webhooks HTTP de forma assíncrona
- 💾 **Persistência de Dados**: Armazena transações em banco de dados SQLite para auditoria
- 📧 **Sistema de Notificações**: Envia notificações personalizáveis baseadas nos eventos recebidos
- ✅ **Validação Robusta**: Valida dados de entrada com verificação de integridade
- 🚀 **Alta Performance**: Construído com Lwt para programação assíncrona eficiente
- 📊 **Logging Estruturado**: Sistema de logs detalhado para monitoramento e debug

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   HTTP Client   │───▶│   Hookinator     │───▶│   Database      │
│   (Webhook)     │◀———│   Server         │    │   (SQLite)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘

```

## 📁 Estrutura do Projeto

```
hookinator/
├── bin/                    # Executável principal
│   ├── dune               # Configuração do executável
│   └── main.ml            # Ponto de entrada da aplicação
├── lib/                   # Biblioteca principal
│   ├── database.ml        # Interface com banco de dados SQLite
│   ├── dune              # Configuração da biblioteca
│   ├── handlers.ml       # Manipuladores de requisições HTTP
│   ├── hookinator.ml     # Módulo principal e API pública
│   ├── notification.ml   # Sistema de notificações
│   ├── transaction.ml    # Lógica de transações e modelos
│   ├── types.ml         # Definições de tipos compartilhados
│   └── validation.ml     # Validação de dados e schemas
├── test/                 # Testes
│   ├── dune             # Configuração de testes
│   └── test_hookinator.ml # Testes unitários
├── dune-project         # Configuração do projeto Dune
├── hookinator.opam      # Metadados do pacote OPAM
├── test_webhook.py      # Script de teste Python
├── webhook_transactions.db # Banco de dados SQLite
└── LICENSE              # Licença MIT
```

### 📋 Descrição dos Módulos

- **[`bin/main.ml`](bin/main.ml)**: Ponto de entrada que inicializa o servidor HTTP
- **[`lib/hookinator.ml`](lib/hookinator.ml)**: API principal e orquestração dos componentes
- **[`lib/handlers.ml`](lib/handlers.ml)**: Manipuladores de rotas HTTP e processamento de webhooks
- **[`lib/database.ml`](lib/database.ml)**: Camada de abstração para operações com SQLite
- **[`lib/transaction.ml`](lib/transaction.ml)**: Modelos de dados e lógica de transações
- **[`lib/notification.ml`](lib/notification.ml)**: Sistema de envio de notificações
- **[`lib/validation.ml`](lib/validation.ml)**: Validação de payloads e schemas JSON
- **[`lib/types.ml`](lib/types.ml)**: Tipos de dados compartilhados entre módulos

## 🚀 Início Rápido

### Pré-requisitos

- **OCaml** >= 5.2.0
- **Dune** >= 3.0
- **OPAM** >= 2.1
- **Python 3** (para testes)

#### Dependências OCaml

As dependências são gerenciadas pelo arquivo [`hookinator.opam`](hookinator.opam).

### 📦 Instalação

1. **Clone o repositório**:
   ```bash
   git clone <repository-url>
   cd hookinator
   ```

2. **Configure o ambiente OCaml**:
   ```bash
   # Se necessário, crie um switch local
   opam switch create . 5.2.0

   # Instale as dependências
   opam install . --deps-only --with-test
   ```

3. **Compile o projeto**:
   ```bash
   dune build
   ```

### ▶️ Executando

#### Iniciar o Servidor

```bash
# Executar diretamente
dune exec hookinator

# Em modo de desenvolvimento (com logs verbosos)
HOOKINATOR_LOG_LEVEL=debug dune exec hookinator

# Especificar porta customizada
HOOKINATOR_PORT=8080 dune exec hookinator
```

O servidor estará disponível em `http://localhost:3000` (ou na porta especificada).

#### Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `HOOKINATOR_PORT` | `3000` | Porta do servidor HTTP |
| `HOOKINATOR_DB_PATH` | `webhook_transactions.db` | Caminho do banco SQLite |
| `HOOKINATOR_LOG_LEVEL` | `info` | Nível de log (`debug`, `info`, `warn`, `error`) |
| `HOOKINATOR_MAX_PAYLOAD_SIZE` | `1MB` | Tamanho máximo do payload |

### 🔧 Configuração

#### Exemplo de Payload de Webhook

```json
{ 
"event": "payment_success",
"transaction_id": "abc123",
"amount": 49.90,
"currency": "BRL",
"timestamp": "2025-05-11T16:00:00Z" 
}
```

#### Endpoints Disponíveis

- `POST /webhook` - Receber webhooks
- `GET /health` - Status do serviço
- `GET /metrics` - Métricas básicas (opcional)

## 🧪 Testando

### Testes Unitários

```bash
# Executar todos os testes
dune test

# Executar com saída verbosa
dune test --verbose

# Executar testes específicos
dune exec test/test_hookinator.exe
```

### Teste de Integração

O projeto inclui um script Python para testar o endpoint de webhook:

```bash
# Certifique-se de que o servidor está rodando
dune exec hookinator &

# Execute o teste
python test_webhook.py

# Parar o servidor
kill %1
```

### Teste Manual com cURL

```bash
# Testar endpoint de webhook
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "event": "test.event",
    "timestamp": "2024-01-15T10:30:00Z",
    "data": {"test": true}
  }'

# Verificar saúde do serviço
curl http://localhost:3000/health
```

## 📊 Monitoramento

### Logs

O Hookinator utiliza logging estruturado. Os logs incluem:
- Requisições recebidas
- Transações processadas
- Erros de validação
- Notificações enviadas

### Métricas

O banco de dados SQLite ([`webhook_transactions.db`](webhook_transactions.db)) armazena:
- Histórico de todas as transações
- Timestamps de processamento
- Status de processamento
- Metadados dos webhooks

## 🔒 Segurança

- Validação de assinatura de webhooks
- Limitação de tamanho de payload
- Sanitização de dados de entrada
- Logs de auditoria completos

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

- Use `dune fmt` para formatação
- Execute `dune test` antes de commits
- Siga as convenções de naming do OCaml
- Documente funções públicas

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

⭐ Se este projeto foi útil, considere dar uma estrela no GitHub!