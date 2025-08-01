# Hookinator

<!-- Linha 1 — visibilidade geral -->
![GitHub Repo stars](https://img.shields.io/github/stars/talesitf/hookinator?style=social)
![GitHub forks](https://img.shields.io/github/forks/talesitf/hookinator?style=social)

<!-- Linha 2 — build, cobertura e licença -->
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![OCaml 5.2](https://img.shields.io/badge/OCaml-5.2%2B-orange.svg)
![Lwt](https://img.shields.io/badge/Lwt-async-blueviolet)
![Last commit](https://img.shields.io/github/last-commit/talesitf/hookinator)

**Hookinator** é um projeto desenvolvido em **OCaml**, utilizando a biblioteca `Lwt` para construir um servidor assíncrono robusto de webhooks. Seu objetivo é demonstrar como a **programação funcional** pode ser aplicada para tornar a comunicação via webhooks HTTP mais eficiente e robusta, promovendo boas práticas de desenvolvimento.

O projeto simula todo o ciclo de vida de um webhook: recepção via HTTP, validação rigorosa de payloads, persistência de transações em **SQLite** e envio de notificações baseadas em eventos. Boas práticas de arquitetura funcional, logging estruturado e modularização tornam o Hookinator um exemplo prático de como estruturar sistemas reativos com OCaml, facilitando manutenção e evolução do código.

## Funcionalidades

- 🔄 **Processamento de Webhooks**: Recebe e processa webhooks HTTP de forma assíncrona
- 💾 **Persistência de Dados**: Armazena transações em banco de dados SQLite para auditoria
- 📧 **Sistema de Notificações**: Envia notificações personalizáveis baseadas nos eventos recebidos
- ✅ **Validação Robusta**: Valida dados de entrada com verificação de integridade e tipos de eventos
- 🔧 **Configuração Automática**: Carregamento automático de variáveis de ambiente via arquivo `.env`
- 🚀 **Alta Performance**: Construído com Lwt para programação assíncrona eficiente
- 📊 **Logging Estruturado**: Sistema de logs detalhado para monitoramento e debug
- 🧪 **Testes Integrados**: Suite completa de testes unitários com Alcotest

## Arquitetura

O sistema segue uma arquitetura modular baseada em componentes funcionais:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   HTTP Client   │───▶│   Hookinator     │───▶│   Database      │
│   (Webhook)     │◀———│   Server         │    │   (SQLite)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │ Notification │
                       │   System     │
                       └──────────────┘
```

## Estrutura do Projeto

```
hookinator/
├── bin/                    # Executável principal
│   ├── dune                # Configuração do executável
│   └── main.ml             # Ponto de entrada da aplicação
├── lib/                    # Biblioteca principal
│   ├── config.ml           # Configurações e carregamento do .env
│   ├── database.ml         # Interface com banco de dados SQLite
│   ├── dune                # Configuração da biblioteca
│   ├── handlers.ml         # Manipuladores de requisições HTTP
│   ├── hookinator.ml       # Módulo principal e API pública
│   ├── notification.ml     # Sistema de notificações
│   ├── transaction.ml      # Lógica de transações e modelos
│   ├── types.ml            # Definições de tipos compartilhados
│   └── validation.ml       # Validação de dados e schemas
├── test/                   # Testes
│   ├── dune                # Configuração de testes
│   └── test_hookinator.ml  # Testes unitários
├── .env                    # Configurações de ambiente (criado pelo usuário)
├── dune-project            # Configuração do projeto Dune
├── hookinator.opam         # Metadados do pacote OPAM
├── webhook_transactions.db # Banco de dados SQLite
└── LICENSE                 # Licença MIT
```

### Descrição dos Módulos

- **[`bin/main.ml`](bin/main.ml)**: Ponto de entrada que inicializa o servidor HTTP
- **[`lib/hookinator.ml`](lib/hookinator.ml)**: API principal e orquestração dos componentes
- **[`lib/config.ml`](lib/config.ml)**: Gerenciamento de configurações
- **[`lib/handlers.ml`](lib/handlers.ml)**: Manipuladores de rotas HTTP e processamento de webhooks
- **[`lib/database.ml`](lib/database.ml)**: Camada de abstração para operações com SQLite
- **[`lib/transaction.ml`](lib/transaction.ml)**: Modelos de dados e lógica de transações
- **[`lib/notification.ml`](lib/notification.ml)**: Sistema de envio de notificações
- **[`lib/validation.ml`](lib/validation.ml)**: Validação robusta de payloads e eventos
- **[`lib/types.ml`](lib/types.ml)**: Tipos de dados compartilhados entre módulos

## Início Rápido

### Pré-requisitos

- **OCaml** >= 5.2.0
- **Dune** >= 3.0
- **OPAM** >= 2.1

#### Dependências OCaml

As dependências são gerenciadas pelo arquivo [`hookinator.opam`](hookinator.opam).

### Instalação

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

### Configuração

#### Arquivo .env

O Hookinator carrega automaticamente as configurações do arquivo `.env`. Crie um arquivo `.env` na raiz do projeto baseado no exemplo:

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite com suas configurações
nano .env
```

### Executando

#### Subir variáveis de ambiente

Para iniciar o servidor, você pode definir as variáveis de ambiente diretamente ou usar um arquivo `.env` com o arquivo `env_setup.sh`:

```bash
source env_setup.sh
```

#### Iniciar o Servidor

```bash
# Executar diretamente
dune exec hookinator

# Em modo de desenvolvimento (com logs verbosos)
HOOKINATOR_LOG_LEVEL=debug dune exec hookinator

# Especificar porta customizada (sobrescreve .env)
HOOKINATOR_PORT=8080 dune exec hookinator
```

O servidor estará disponível em `http://localhost:3000` (ou na porta especificada).

#### Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `HOOKINATOR_PORT` | `3000` | Porta do servidor HTTP |
| `HOOKINATOR_DB_PATH` | `webhook_transactions.db` | Caminho do banco SQLite |
| `HOOKINATOR_LOG_LEVEL` | `info` | Nível de log (`debug`, `info`, `warn`, `error`) |
| `HOOKINATOR_TOKEN` | *(obrigatório)* | Token de autenticação para webhooks |
| `HOOKINATOR_EXPECTED_AMOUNT` | `49.90` | Valor esperado para validação |
| `HOOKINATOR_EXPECTED_CURRENCY` | `BRL` | Moeda esperada para validação |
| `HOOKINATOR_CONFIRM_URL` | `http://localhost:8000/confirmar` | URL de confirmação |
| `HOOKINATOR_CANCEL_URL` | `http://localhost:8000/cancelar` | URL de cancelamento |
| `HOOKINATOR_MAX_PAYLOAD_SIZE` | `1048576` | Tamanho máximo do payload (bytes) |
| `HOOKINATOR_MIN_TRANSACTION_ID_LENGTH` | `5` | Tamanho mínimo do ID da transação |

### Webhooks

#### Exemplo de Payload de Webhook

```json
{ 
  "event": "payment_success",
  "transaction_id": "abc123",
  "amount": "49.90",
  "currency": "BRL",
  "timestamp": "2024-01-01T12:00:00Z" 
}
```

#### Eventos Válidos

O sistema valida rigorosamente os tipos de eventos aceitos:

- `payment_success` - Pagamento processado com sucesso
- `payment_failed` - Falha no processamento do pagamento
- `payment_pending` - Pagamento pendente de confirmação
- `subscription_created` - Nova assinatura criada
- `subscription_cancelled` - Assinatura cancelada
- `refund_processed` - Reembolso processado

#### Endpoints Disponíveis

- `POST /webhook` - Receber webhooks (requer token de autenticação)
- `GET /health` - Status do serviço
- `GET /metrics` - Métricas básicas (opcional)

## Testando

### Testes Unitários

O projeto inclui uma suíte completa de testes que carrega automaticamente as configurações do `.env`:

```bash
# Executar todos os testes
dune test

# Executar com saída verbosa
dune test --verbose

# Executar testes específicos
dune exec test/test_hookinator.exe
```

Os testes cobrem:

- Validação de payloads válidos e inválidos
- Verificação de tipos de eventos
- Autenticação de transações
- Validação de configurações

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
# Testar endpoint de webhook com evento válido
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer seu-token-secreto-aqui" \
  -d '{
    "event": "payment_success",
    "transaction_id": "test123",
    "amount": "49.90",
    "currency": "BRL",
    "timestamp": "2024-01-01T12:00:00Z"
  }'

# Testar com evento inválido
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer seu-token-secreto-aqui" \
  -d '{
    "event": "invalid_event",
    "transaction_id": "test123",
    "amount": "49.90",
    "currency": "BRL",
    "timestamp": "2024-01-01T12:00:00Z"
  }'

# Verificar saúde do serviço
curl http://localhost:3000/health
```

## Monitoramento

### Logs

O Hookinator utiliza logging estruturado com diferentes níveis de verbosidade. Os logs incluem:

- Requisições recebidas
- Transações processadas
- Validações de eventos
- Erros de validação
- Notificações enviadas
- Carregamento de configurações

### Persistência de Dados

O banco de dados SQLite ([`webhook_transactions.db`](webhook_transactions.db)) armazena:

- Histórico de todas as transações
- Timestamps de processamento
- Status de processamento
- Metadados dos webhooks

## Segurança

- **Validação de token**: Autenticação obrigatória via header Authorization
- **Validação de eventos**: Apenas eventos predefinidos são aceitos
- **Limitação de payload**: Tamanho máximo configurável
- **Sanitização de dados**: Validação rigorosa de tipos e formatos
- **Logs de auditoria**: Registro completo de todas as operações
- **Configuração segura**: Carregamento automático de variáveis sensíveis via `.env`

## Contribuição

Contribuições são bem-vindas! Para contribuir:

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
- Mantenha o arquivo `.env.example` atualizado
- Adicione testes para novas funcionalidades

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

⭐ Se este projeto foi útil, considere dar uma estrela no GitHub!

> O Hookinator foi idealizado como uma demonstração técnica para explorar, de forma aplicada, conceitos aprendidos em sala de aula sobre programação funcional, concorrência assíncrona e arquitetura de sistemas distribuídos.
