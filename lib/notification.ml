open Lwt.Syntax

let notificar_servico_externo url payload =
  Logs.info (fun m -> m "Notificando serviço externo em: %s" url);
  let uri = Uri.of_string url in
  let headers = Cohttp.Header.init_with "Content-Type" "application/json" in
  let body_str = Yojson.Basic.to_string payload in
  let body = Cohttp_lwt.Body.of_string body_str in
  
  Lwt.catch
    (fun () ->
      let* response, _ = Cohttp_lwt_unix.Client.post ~headers ~body uri in
      let status_code = Cohttp.Response.status response |> Cohttp.Code.code_of_status in
      if status_code >= 200 && status_code < 300 then
        Logs.info (fun m -> m "Notificação enviada com sucesso para %s" url)
      else
        Logs.warn (fun m -> m "Falha ao notificar %s - Status: %d" url status_code);
      Lwt.return_unit)
    (fun exn ->
      Logs.err (fun m -> m "Erro ao notificar %s: %s" url (Printexc.to_string exn));
      Lwt.return_unit)

let confirmar_transacao payment =
  let payload = `Assoc [
    ("transaction_id", `String payment.Types.transaction_id);
    ("event", `String payment.event);
    ("amount", `Float payment.amount);
    ("currency", `String payment.currency);
    ("timestamp", `String payment.timestamp);
  ] in
  notificar_servico_externo Config.notification_confirm_url payload

let cancelar_transacao payment =
  let payload = `Assoc [
    ("transaction_id", `String payment.Types.transaction_id);
    ("event", `String payment.event);
    ("reason", `String "Validation failed");
  ] in
  notificar_servico_externo Config.notification_cancel_url payload