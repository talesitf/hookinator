open Yojson.Basic.Util
open Types

(* Função para validar integridade do payload *)
let validate_payload json =
  try
    let event = json |> member "event" |> to_string in
    let transaction_id = json |> member "transaction_id" |> to_string in
    let amount_str = json |> member "amount" |> to_string in
    let amount = Float.of_string amount_str in
    let currency = json |> member "currency" |> to_string in
    let timestamp = json |> member "timestamp" |> to_string in
    
    (* Validações básicas *)
    if String.length transaction_id < 5 then
      Error "Transaction ID deve ter pelo menos 5 caracteres"
    else if amount <= 0.0 then
      Error "Amount deve ser maior que zero"
    else if String.length currency <> 3 then
      Error "Currency deve ter 3 caracteres"
    else if event <> "payment_success" && event <> "payment_pending" then
      Error "Event deve ser 'payment_success' ou 'payment_pending'"
    else
      Ok { event; transaction_id; amount; currency; timestamp }
  with
  | Type_error (msg, _) -> Error ("Erro de tipo no JSON: " ^ msg)
  | Failure _ -> Error "Amount deve ser um número válido"
  | exn -> Error ("Erro ao validar payload: " ^ Printexc.to_string exn)

(* Função para verificar autenticidade da transação *)
let verify_transaction_authenticity payment =
  let timestamp_valid = 
    try
      let has_t = String.contains payment.timestamp 'T' in
      let has_z = String.contains payment.timestamp 'Z' in
      has_t && has_z
    with _ -> false
  in
  
  if not timestamp_valid then
    Error "Formato de timestamp inválido"
  else if String.length payment.transaction_id < 6 then
    Error "Transaction ID suspeito - muito curto"
  else if not (String.for_all (function 'a'..'z' | 'A'..'Z' | '0'..'9' -> true | _ -> false) payment.transaction_id) then
    Error "Transaction ID contém caracteres suspeitos"
  else
    Ok ()