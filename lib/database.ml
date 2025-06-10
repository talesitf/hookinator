open Types

(* Função para limpar todas as transações do banco (para testes) *)
let clear_database () =
  let db = Sqlite3.db_open db_path in
  let delete_sql = "DELETE FROM transactions" in
  let rc = Sqlite3.exec db delete_sql in
  (match rc with
   | Sqlite3.Rc.OK -> Logs.info (fun m -> m "Database cleared successfully")
   | _ -> Logs.err (fun m -> m "Failed to clear database: %s" (Sqlite3.Rc.to_string rc)));
  let _ = Sqlite3.db_close db in
  ()

(* Função para inicializar o banco de dados *)
let init_database () =
  let db = Sqlite3.db_open db_path in
  let create_table_sql = {|
    CREATE TABLE IF NOT EXISTS transactions (
      transaction_id TEXT PRIMARY KEY,
      event TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      status TEXT NOT NULL CHECK(status IN ('confirmed', 'cancelled')),
      processed_at REAL NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  |} in
  let rc = Sqlite3.exec db create_table_sql in
  (match rc with
   | Sqlite3.Rc.OK -> Logs.info (fun m -> m "Database initialized successfully")
   | _ -> Logs.err (fun m -> m "Failed to initialize database: %s" (Sqlite3.Rc.to_string rc)));
  let _ = Sqlite3.db_close db in
  ()

(* Função para verificar se transação já existe no DB *)
let transaction_exists transaction_id =
  let db = Sqlite3.db_open db_path in
  let select_sql = "SELECT status FROM transactions WHERE transaction_id = ?" in
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
  let _ = Sqlite3.db_close db in
  result

(* Função para persistir transação no banco de dados *)
let persist_transaction payment status =
  let db = Sqlite3.db_open db_path in
  let status_str = match status with 
    | Confirmed -> "confirmed" 
    | Cancelled -> "cancelled" in
  let processed_at = Unix.time () in
  
  let insert_sql = {|
    INSERT OR REPLACE INTO transactions 
    (transaction_id, event, amount, currency, timestamp, status, processed_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  |} in
  
  let stmt = Sqlite3.prepare db insert_sql in
  let rc = Sqlite3.bind_values stmt [
    Sqlite3.Data.TEXT payment.transaction_id;
    Sqlite3.Data.TEXT payment.event;
    Sqlite3.Data.FLOAT payment.amount;
    Sqlite3.Data.TEXT payment.currency;
    Sqlite3.Data.TEXT payment.timestamp;
    Sqlite3.Data.TEXT status_str;
    Sqlite3.Data.FLOAT processed_at;
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
  let _ = Sqlite3.db_close db in
  ()