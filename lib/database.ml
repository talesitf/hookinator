open Types

let db_connection = ref None

let get_connection () =
  match !db_connection with
  | Some conn -> conn
  | None ->
    let conn = Sqlite3.db_open Config.db_path in
    db_connection := Some conn;
    conn

(* Função para limpar todas as transações do banco (para testes) *)
let clear_database () =
  let db = get_connection () in
  let delete_sql = "DELETE FROM webhook_transactions" in
  let rc = Sqlite3.exec db delete_sql in
  (match rc with
   | Sqlite3.Rc.OK -> Logs.info (fun m -> m "Database cleared successfully")
   | _ -> Logs.err (fun m -> m "Failed to clear database: %s" (Sqlite3.Rc.to_string rc)));
  ()

(* Função para inicializar o banco de dados *)
let init_database () =
  let conn = get_connection () in
  let create_table_sql = {|
    CREATE TABLE IF NOT EXISTS webhook_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id TEXT UNIQUE NOT NULL,
      event TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  |} in
  match Sqlite3.exec conn create_table_sql with
  | Sqlite3.Rc.OK -> 
    Logs.info (fun m -> m "Banco de dados inicializado: %s" Config.db_path)
  | rc -> 
    Logs.err (fun m -> m "Erro ao criar tabela: %s" (Sqlite3.Rc.to_string rc));
    failwith "Falha na inicialização do banco de dados"

(* Função para verificar se transação já existe no DB *)
let transaction_exists transaction_id =
  let db = get_connection () in
  let select_sql = "SELECT status FROM webhook_transactions WHERE transaction_id = ?" in
  let stmt = Sqlite3.prepare db select_sql in
  let _ = Sqlite3.bind_values stmt [Sqlite3.Data.TEXT transaction_id] in
  
  let result = 
    match Sqlite3.step stmt with
    | Sqlite3.Rc.ROW ->
        (match Sqlite3.column stmt 0 with
         | Sqlite3.Data.TEXT "confirmed" -> Some Confirmed
         | Sqlite3.Data.TEXT "cancelled" -> Some Cancelled
         | _ -> None)
    | _ -> None
  in
  
  let _ = Sqlite3.finalize stmt in
  result

(* Função para persistir transação no banco de dados *)
let persist_transaction payment status =
  let db = get_connection () in
  let status_str = match status with 
    | Confirmed -> "confirmed" 
    | Cancelled -> "cancelled" in
  
  let insert_sql = {|
    INSERT OR REPLACE INTO webhook_transactions 
    (transaction_id, event, amount, currency, timestamp, status, created_at)
    VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
  |} in
  
  let stmt = Sqlite3.prepare db insert_sql in
  let rc = Sqlite3.bind_values stmt [
    Sqlite3.Data.TEXT payment.transaction_id;
    Sqlite3.Data.TEXT payment.event;
    Sqlite3.Data.FLOAT payment.amount;
    Sqlite3.Data.TEXT payment.currency;
    Sqlite3.Data.TEXT payment.timestamp;
    Sqlite3.Data.TEXT status_str;
  ] in
  
  (match rc with
   | Sqlite3.Rc.OK ->
       let step_rc = Sqlite3.step stmt in
       (match step_rc with
        | Sqlite3.Rc.DONE ->
            Logs.info (fun m -> m "Transação %s persistida no DB com status: %s" 
              payment.transaction_id status_str)
        | _ ->
            Logs.err (fun m -> m "Erro ao inserir transação: %s" (Sqlite3.Rc.to_string step_rc)))
   | _ ->
       Logs.err (fun m -> m "Erro ao preparar statement: %s" (Sqlite3.Rc.to_string rc)));
  
  let _ = Sqlite3.finalize stmt in
  ()