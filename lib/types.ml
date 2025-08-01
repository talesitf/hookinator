(* Tipos de dados principais *)

type transaction_status = 
  | Confirmed
  | Cancelled

type payment = {
  event: string;
  transaction_id: string;
  amount: float;
  currency: string;
  timestamp: string;
}

(* Função para verificar se é o valor esperado *)
let is_expected_amount amount =
  abs_float (amount -. Config.expected_amount) < 0.001

(* Função para verificar se é a moeda esperada *)
let is_expected_currency currency =
  String.equal currency Config.expected_currency

(* Função para validar pagamento de acordo com configuração *)
let validate_payment_config payment =
  let errors = ref [] in
  
  if not (is_expected_amount payment.amount) then
    errors := Printf.sprintf "Valor deve ser %.2f, recebido %.2f" 
      Config.expected_amount payment.amount :: !errors;
  
  if not (is_expected_currency payment.currency) then
    errors := Printf.sprintf "Moeda deve ser %s, recebido %s" 
      Config.expected_currency payment.currency :: !errors;
  
  match !errors with
  | [] -> Ok ()
  | errs -> Error (String.concat "; " errs)

(* Configuração do banco de dados *)
let db_path = "webhook_transactions.db"
let expected_token = "meu-token-secreto"