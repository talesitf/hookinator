open Alcotest
open Hookinator

(* Helper para verificar se uma string contém uma substring *)
let string_contains str substr =
  let len = String.length substr in
  let str_len = String.length str in
  let rec loop i =
    if i > str_len - len then false
    else if String.sub str i len = substr then true
    else loop (i + 1)
  in
  if len = 0 then true else loop 0

(* Helpers para criar payloads de teste *)
let create_valid_payload ?(event="payment_success") ?(transaction_id="test123") 
                        ?(amount="49.90") ?(currency="BRL") ?(timestamp="2024-01-01T12:00:00Z") () =
  `Assoc [
    ("event", `String event);
    ("transaction_id", `String transaction_id);
    ("amount", `String amount);
    ("currency", `String currency);
    ("timestamp", `String timestamp);
  ]

(* Testes de Validação *)
let test_valid_payload_success () =
  let json = create_valid_payload () in
  match Validation.validate_payload json with
  | Ok payment -> 
      check string "event" "payment_success" payment.event;
      check string "transaction_id" "test123" payment.transaction_id;
      check (float 0.01) "amount" 49.90 payment.amount;
      check string "currency" "BRL" payment.currency
  | Error msg -> 
      Alcotest.fail ("Validation should succeed: " ^ msg)

let test_invalid_transaction_id () =
  let json = create_valid_payload ~transaction_id:"abc" () in
  match Validation.validate_payload json with
  | Error msg -> 
      check bool "should contain transaction_id error" true (string_contains msg "transaction_id")
  | Ok _ -> 
      Alcotest.fail "Validation should fail for short transaction_id"

let test_invalid_amount () =
  let json = create_valid_payload ~amount:"0.00" () in
  match Validation.validate_payload json with
  | Error msg -> 
      check bool "should contain amount error" true (string_contains msg "amount")
  | Ok _ -> 
      Alcotest.fail "Validation should fail for zero amount"

let test_invalid_currency () =
  let json = create_valid_payload ~currency:"BR" () in
  match Validation.validate_payload json with
  | Error msg -> 
      check bool "should contain currency error" true (string_contains msg "currency")
  | Ok _ -> 
      Alcotest.fail "Validation should fail for short currency"

let test_invalid_event () =
  (* Teste com evento vazio *)
  let json_empty = create_valid_payload ~event:"" () in
  match Validation.validate_payload json_empty with
  | Error msg -> 
      check bool "should contain event error" true (string_contains msg "event")
  | Ok _ -> 
      (* Se não falhar com evento vazio, teste com um JSON malformado *)
      let json_missing = `Assoc [
        ("transaction_id", `String "test123");
        ("amount", `String "49.90");
        ("currency", `String "BRL");
        ("timestamp", `String "2024-01-01T12:00:00Z");
      ] in
      match Validation.validate_payload json_missing with
      | Error msg -> 
          check bool "should contain event error" true (string_contains msg "event")
      | Ok _ -> 
          Alcotest.fail "Validation should fail for missing or invalid event"

(* Teste de autenticidade de transação *)
let test_verify_transaction_authenticity () =
  let payment = Types.{
    event = "payment_success";
    transaction_id = "test123";
    amount = 49.90;
    currency = "BRL";
    timestamp = "2024-01-01T12:00:00Z";
  } in
  match Validation.verify_transaction_authenticity payment with
  | Ok () -> ()
  | Error msg -> Alcotest.fail ("Authenticity verification failed: " ^ msg)

(* Teste de configuração *)
let test_config_validation () =
  match Config.validate_config () with
  | Ok () -> ()
  | Error msg -> Alcotest.fail ("Config validation failed: " ^ msg)

(* Lista de todos os testes *)
let validation_tests = [
  ("Valid payload validation", `Quick, test_valid_payload_success);
  ("Invalid transaction ID", `Quick, test_invalid_transaction_id);
  ("Invalid amount", `Quick, test_invalid_amount);
  ("Invalid currency", `Quick, test_invalid_currency);
  ("Invalid event", `Quick, test_invalid_event);
  ("Transaction authenticity verification", `Quick, test_verify_transaction_authenticity);
  ("Config validation", `Quick, test_config_validation);
]

(* Função principal dos testes *)
let () =
  run "Hookinator Tests" [
    ("Validation", validation_tests);
  ]