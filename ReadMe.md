# Hookinator

Hookinator é um serviço de webhook escrito em OCaml. Ele recebe webhooks, processa transações e envia notificações.

## Funcionalidades

* Recebe e processa webhooks.
* Armazena transações em um banco de dados SQLite.
* Envia notificações (a implementação específica de notificação pode variar).
* Valida os dados recebidos.

## Estrutura do Projeto

*   **`bin/`**: Contém o executável principal.
    *   [`main.ml`](bin/main.ml): Ponto de entrada da aplicação.
*   **`lib/`**: Contém a lógica principal da aplicação.
    *   [`hookinator.ml`](lib/hookinator.ml): Módulo principal da biblioteca Hookinator.
    *   [`handlers.ml`](lib/handlers.ml): Lida com as requisições HTTP e webhooks.
    *   [`database.ml`](lib/database.ml): Interage com o banco de dados SQLite.
    *   [`transaction.ml`](lib/transaction.ml): Define a estrutura e lógica de transações.
    *   [`notification.ml`](lib/notification.ml): Lida com o envio de notificações.
    *   [`validation.ml`](lib/validation.ml): Realiza a validação dos dados.
    *   [`types.ml`](lib/types.ml): Define os tipos de dados usados no projeto.
*   **`test/`**: Contém os testes.
    *   [`test_hookinator.ml`](test/test_hookinator.ml): Testes unitários em OCaml.
    *   [`test_webhook.py`](test_webhook.py): Script Python para testar o endpoint do webhook.
*   **`dune-project`**: Arquivo de configuração do Dune para o projeto.
*   **`hookinator.opam`**: Arquivo de metadados do pacote OPAM.
*   **`LICENSE`**: Licença do projeto ([MIT](LICENSE)).
*   **`webhook_transactions.db`**: Arquivo de banco de dados SQLite (gerado em tempo de execução).

## Pré-requisitos

*   OCaml
*   Dune
*   OPAM
*   Bibliotecas OCaml listadas no arquivo `hookinator.opam` (ex: `opium`, `lwt`, `sqlite3`, `cohttp`, etc.)
*   Python 3 (para executar o script de teste `test_webhook.py`)

## Construindo o Projeto

1.  Instale as dependências do OPAM:
    ```sh
    opam install . --deps-only --with-test
    ```
2.  Construa o projeto usando Dune:
    ```sh
    dune build
    ```

## Executando

Para iniciar o servidor Hookinator:

```sh
dune exec hookinator
```

Por padrão, o servidor deve iniciar e escutar por requisições HTTP na porta especificada na configuração (geralmente definida em [`bin/main.ml`](bin/main.ml) ou através de variáveis de ambiente).

## Testando

### Testes Unitários (OCaml)

Para executar os testes unitários definidos em [`test/test_hookinator.ml`](test/test_hookinator.ml):

```sh
dune test
```

### Teste de Webhook (Python)

O script [`test_webhook.py`](test_webhook.py) pode ser usado para enviar uma requisição de teste para o endpoint do webhook. Certifique-se de que o servidor Hookinator esteja em execução antes de rodar este script.

```sh
python test_webhook.py
```

Você pode precisar ajustar o URL e o payload no script [`test_webhook.py`](test_webhook.py) conforme necessário.

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.