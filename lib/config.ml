(* Configurações de segurança *)
let expected_token = 
  match Sys.getenv_opt "HOOKINATOR_TOKEN" with
  | Some token when String.length token > 0 -> token
  | _ -> failwith "HOOKINATOR_TOKEN deve ser definido como variável de ambiente"

(* Configurações de transação *)
let expected_amount = 
  match Sys.getenv_opt "HOOKINATOR_EXPECTED_AMOUNT" with
  | Some amount_str ->
    (try float_of_string amount_str
     with Failure _ -> failwith "HOOKINATOR_EXPECTED_AMOUNT deve ser um número válido")
  | None -> 49.90 (* valor padrão para compatibilidade *)

let expected_currency =
  Sys.getenv_opt "HOOKINATOR_EXPECTED_CURRENCY" 
  |> Option.value ~default:"BRL"

(* Configurações do banco de dados *)
let db_path = 
  Sys.getenv_opt "HOOKINATOR_DB_PATH" 
  |> Option.value ~default:"webhook_transactions.db"

(* Configurações do servidor *)
let server_port = 
  match Sys.getenv_opt "HOOKINATOR_PORT" with
  | Some port_str ->
    (try int_of_string port_str
     with Failure _ -> 3000)
  | None -> 3000

(* Configurações de logging *)
let log_level = 
  match Sys.getenv_opt "HOOKINATOR_LOG_LEVEL" with
  | Some "debug" -> Logs.Debug
  | Some "info" -> Logs.Info
  | Some "warn" -> Logs.Warning
  | Some "error" -> Logs.Error
  | _ -> Logs.Info

(* Configurações de notificação *)
let notification_confirm_url =
  Sys.getenv_opt "HOOKINATOR_CONFIRM_URL"
  |> Option.value ~default:"http://localhost:8000/confirmar"

let notification_cancel_url =
  Sys.getenv_opt "HOOKINATOR_CANCEL_URL"
  |> Option.value ~default:"http://localhost:8000/cancelar"

(* Configurações de validação *)
let max_payload_size_bytes =
  match Sys.getenv_opt "HOOKINATOR_MAX_PAYLOAD_SIZE" with
  | Some size_str ->
    (try int_of_string size_str
     with Failure _ -> 1024 * 1024) (* 1MB padrão *)
  | None -> 1024 * 1024

let min_transaction_id_length =
  match Sys.getenv_opt "HOOKINATOR_MIN_TRANSACTION_ID_LENGTH" with
  | Some len_str ->
    (try int_of_string len_str
     with Failure _ -> 5)
  | None -> 5

(* Função para validar configurações na inicialização *)
let validate_config () =
  let errors = ref [] in
  
  (* Validar token *)
  if String.length expected_token < 10 then
    errors := "Token deve ter pelo menos 10 caracteres" :: !errors;
  
  (* Validar amount *)
  if expected_amount <= 0.0 then
    errors := "Valor esperado deve ser positivo" :: !errors;
  
  (* Validar porta *)
  if server_port < 1 || server_port > 65535 then
    errors := "Porta deve estar entre 1 e 65535" :: !errors;
  
  (* Validar tamanho do payload *)
  if max_payload_size_bytes <= 0 then
    errors := "Tamanho máximo do payload deve ser positivo" :: !errors;
  
  match !errors with
  | [] -> Ok ()
  | errs -> Error (String.concat "; " errs)

(* Função para imprimir configuração atual *)
let print_config () =
  Logs.info (fun m -> m "=== Configuração do Hookinator ===");
  Logs.info (fun m -> m "Porta: %d" server_port);
  Logs.info (fun m -> m "Banco de dados: %s" db_path);
  Logs.info (fun m -> m "Valor esperado: %.2f %s" expected_amount expected_currency);
  Logs.info (fun m -> m "Nível de log: %s" 
    (match log_level with
     | Logs.Debug -> "debug"
     | Logs.Info -> "info" 
     | Logs.Warning -> "warn"
     | Logs.Error -> "error"
     | _ -> "unknown"));
  Logs.info (fun m -> m "URL confirmação: %s" notification_confirm_url);
  Logs.info (fun m -> m "URL cancelamento: %s" notification_cancel_url);
  Logs.info (fun m -> m "===================================")