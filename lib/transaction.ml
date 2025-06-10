open Lwt.Syntax
open Opium
open Types

(* Função para cancelar transação *)
let cancel_transaction payment basic_json reason =
  Logs.warn (fun m -> m "Cancelando transação %s - Motivo: %s" payment.transaction_id reason);
  Database.persist_transaction payment Cancelled;
  let* () = Notification.notificar_servico_externo "http://localhost:5001/cancelar" basic_json in
  Lwt.return (Response.of_plain_text ("Transação cancelada: " ^ reason) ~status:`Bad_request)

(* Função para confirmar transação *)
let confirm_transaction payment basic_json =
  Logs.info (fun m -> m "Confirmando transação %s" payment.transaction_id);
  Database.persist_transaction payment Confirmed;
  let* () = Notification.notificar_servico_externo "http://localhost:5001/confirmar" basic_json in
  Lwt.return (Response.of_plain_text "Transação processada com sucesso." ~status:`OK)