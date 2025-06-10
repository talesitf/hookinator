type payment = {
  event: string;
  transaction_id: string;
  amount: float;
  currency: string;
  timestamp: string;
}

type transaction_status = 
  | Confirmed
  | Cancelled

(* Configuração do banco de dados *)
let db_path = "webhook_transactions.db"
let expected_token = "meu-token-secreto"