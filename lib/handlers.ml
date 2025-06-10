open Lwt.Syntax
open Opium
open Yojson.Basic.Util
open Types

(* Handler principal do webhook *)
let webhook_handler req =
  Logs.info (fun m -> m "Received webhook request");
  
  let token = Request.header "X-Webhook-Token" req in
  match token with
  | None ->
      Logs.warn (fun m -> m "Missing authentication token");
      Lwt.return (Response.of_plain_text "Unauthorized" ~status:`Unauthorized)
  | Some t when t <> expected_token ->
      Logs.warn (fun m -> m "Invalid authentication token: %s" t);
      Lwt.return (Response.of_plain_text "Unauthorized" ~status:`Unauthorized)
  | Some _ ->
      let* body = Request.to_json req in
      match body with
      | None ->
          Logs.warn (fun m -> m "Failed to parse request body");
          Lwt.return (Response.of_plain_text "Invalid JSON" ~status:`Bad_request)
      | Some json ->
          let basic_json = Yojson.Safe.to_basic json in
          
          match Validation.validate_payload basic_json with
          | Error msg ->
              Logs.warn (fun m -> m "Erro na validação do payload: %s" msg);
              (try
                let _transaction_id = basic_json |> member "transaction_id" |> to_string in
                let* () = Notification.notificar_servico_externo "http://localhost:5001/cancelar" basic_json in
                Lwt.return (Response.of_plain_text ("Payload inválido: " ^ msg) ~status:`Bad_request)
              with
              | _ -> Lwt.return (Response.of_plain_text ("Payload inválido: " ^ msg) ~status:`Bad_request))
          | Ok payment_data ->
              
              match Validation.verify_transaction_authenticity payment_data with
              | Error msg ->
                  Transaction.cancel_transaction payment_data basic_json msg
              | Ok () ->
                  
                  Logs.info (fun m -> m "Processando transação autêntica %s, evento: %s, valor: %.2f %s, timestamp: %s" 
                    payment_data.transaction_id 
                    payment_data.event 
                    payment_data.amount 
                    payment_data.currency
                    payment_data.timestamp);
                  
                  (* Verificar se transação já foi processada no DB *)
                  match Database.transaction_exists payment_data.transaction_id with
                  | Some Confirmed ->
                      Logs.warn (fun m -> m "Transaction ID %s já foi confirmada" payment_data.transaction_id);
                      Lwt.return (Response.of_plain_text "Transaction already processed" ~status:`Conflict)
                  | Some Cancelled ->
                      Logs.warn (fun m -> m "Transaction ID %s foi cancelada anteriormente" payment_data.transaction_id);
                      Lwt.return (Response.of_plain_text "Transação foi cancelada" ~status:`Conflict)
                  | None ->
                      (* Verificar valor esperado *)
                      if payment_data.amount <> 49.90 then
                        Transaction.cancel_transaction payment_data basic_json "Valor de pagamento incorreto"
                      else
                        Transaction.confirm_transaction payment_data basic_json

(* Endpoint para listar transações do DB *)
let list_transactions_handler _req =
  let db = Sqlite3.db_open db_path in
  let select_sql = {|
    SELECT transaction_id, event, amount, currency, timestamp, status, processed_at 
    FROM transactions ORDER BY processed_at DESC LIMIT 100
  |} in
  let stmt = Sqlite3.prepare db select_sql in
  
  let rec collect_results acc =
    match Sqlite3.step stmt with
    | Sqlite3.Rc.ROW ->
        let transaction = `Assoc [
          ("transaction_id", `String (Sqlite3.column_text stmt 0));
          ("event", `String (Sqlite3.column_text stmt 1));
          ("amount", `Float (Sqlite3.column_double stmt 2));
          ("currency", `String (Sqlite3.column_text stmt 3));
          ("timestamp", `String (Sqlite3.column_text stmt 4));
          ("status", `String (Sqlite3.column_text stmt 5));
          ("processed_at", `Float (Sqlite3.column_double stmt 6));
        ] in
        collect_results (transaction :: acc)
    | _ -> List.rev acc
  in
  
  let transactions = collect_results [] in
  let _ = Sqlite3.finalize stmt in
  let _ = Sqlite3.db_close db in
  
  let response_json = `Assoc [("transactions", `List transactions)] in
  Lwt.return (Response.of_json response_json)

(* Endpoint de health check com estatísticas do DB *)
let health_check_handler _req =
  let db = Sqlite3.db_open db_path in
  let count_sql = "SELECT status, COUNT(*) FROM transactions GROUP BY status" in
  let stmt = Sqlite3.prepare db count_sql in
  
  let rec collect_counts confirmed cancelled =
    match Sqlite3.step stmt with
    | Sqlite3.Rc.ROW ->
        let status = Sqlite3.column_text stmt 0 in
        let count = Sqlite3.column_int stmt 1 in
        (match status with
         | "confirmed" -> collect_counts count cancelled
         | "cancelled" -> collect_counts confirmed count
         | _ -> collect_counts confirmed cancelled)
    | _ -> (confirmed, cancelled)
  in
  
  let (confirmed_count, cancelled_count) = collect_counts 0 0 in
  let _ = Sqlite3.finalize stmt in
  let _ = Sqlite3.db_close db in
  
  let response = `Assoc [
    ("status", `String "healthy");
    ("timestamp", `Float (Unix.time ()));
    ("total_transactions", `Int (confirmed_count + cancelled_count));
    ("confirmed_transactions", `Int confirmed_count);
    ("cancelled_transactions", `Int cancelled_count);
    ("database", `String db_path);
  ] in
  Lwt.return (Response.of_json response)

(* Endpoint para limpar banco de dados (apenas para testes) *)
let clear_database_handler _req =
  Database.clear_database ();
  let response = `Assoc [
    ("status", `String "cleared");
    ("timestamp", `Float (Unix.time ()));
    ("message", `String "Database cleared successfully");
  ] in
  Lwt.return (Response.of_json response)