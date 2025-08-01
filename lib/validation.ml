open Yojson.Basic.Util
open Types

(* Lista de eventos válidos *)
let valid_events = [
  "payment_success";
  "payment_failed";
  "payment_pending";
  "subscription_created";
  "subscription_cancelled";
  "refund_processed";
]

(* Função para validar se o evento é válido *)
let validate_event event =
  if String.length event = 0 then
    Error "event não pode estar vazio"
  else if not (List.mem event valid_events) then
    Error (Printf.sprintf "event '%s' não é válido. Eventos válidos: %s" 
           event (String.concat ", " valid_events))
  else
    Ok event

(* Funções auxiliares para extração segura de campos *)
let extract_string_field json field_name =
  try
    Ok (json |> member field_name |> to_string)
  with
  | Type_error _ -> Error (Printf.sprintf "Campo '%s' deve ser uma string" field_name)
  | _ -> Error (Printf.sprintf "Campo '%s' não encontrado" field_name)

let extract_float_field json field_name =
  match extract_string_field json field_name with
  | Error msg -> Error msg
  | Ok str ->
      try
        Ok (Float.of_string str)
      with
      | Failure _ -> Error (Printf.sprintf "Campo '%s' deve ser um número válido" field_name)

(* Funções de validação específicas *)
let validate_transaction_id transaction_id =
  if String.length transaction_id < Config.min_transaction_id_length then
    Error (Printf.sprintf "transaction_id deve ter pelo menos %d caracteres" Config.min_transaction_id_length)
  else
    Ok transaction_id

let validate_currency currency =
  if String.length currency < 3 then
    Error "currency deve ter pelo menos 3 caracteres"
  else
    Ok currency

let validate_amount amount =
  if amount <= 0.0 then
    Error "amount deve ser positivo"
  else
    Ok amount

(* Função para aplicar validações em sequência usando Result.bind *)
let (>>=) = Result.bind

let validate_extracted_fields event transaction_id amount currency timestamp =
  validate_event event >>= fun validated_event ->
  validate_transaction_id transaction_id >>= fun validated_transaction_id ->
  validate_currency currency >>= fun validated_currency ->
  validate_amount amount >>= fun validated_amount ->
  Ok Types.{ 
    event = validated_event; 
    transaction_id = validated_transaction_id; 
    amount = validated_amount; 
    currency = validated_currency; 
    timestamp 
  }

(* Função principal de validação - versão funcional *)
let validate_payload json =
  let extract_all_fields () =
    extract_string_field json "event" >>= fun event ->
    extract_string_field json "transaction_id" >>= fun transaction_id ->
    extract_float_field json "amount" >>= fun amount ->
    extract_string_field json "currency" >>= fun currency ->
    extract_string_field json "timestamp" >>= fun timestamp ->
    Ok (event, transaction_id, amount, currency, timestamp)
  in
  
  extract_all_fields () >>= fun (event, transaction_id, amount, currency, timestamp) ->
  validate_extracted_fields event transaction_id amount currency timestamp >>= fun payment ->
  Types.validate_payment_config payment >>= fun () ->
  Ok payment

(* Função para verificar autenticidade da transação *)
let verify_transaction_authenticity payment =
  (* Validar ID da transação *)
  let transaction_id_regex = Re.Perl.compile_pat "^[a-zA-Z0-9_-]+$" in
  if not (Re.execp transaction_id_regex payment.transaction_id) then
    Error "transaction_id contém caracteres inválidos"
  else
    (* Validar timestamp ISO 8601 *)
    let timestamp_regex = Re.Perl.compile_pat "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z?$" in
    if not (Re.execp timestamp_regex payment.timestamp) then
      Error "timestamp deve estar no formato ISO 8601"
    else
      Ok ()

(* Validar token de autenticação *)
let validate_token request_token =
  if String.equal request_token Config.expected_token then
    Ok ()
  else
    Error "Token de autenticação inválido"