open Lwt.Syntax

(* Função para notificar serviço externo *)
let notificar_servico_externo url payload =
  Logs.info (fun m -> m "Notificando serviço externo em: %s" url);
  let uri = Uri.of_string url in
  let headers = Cohttp.Header.init_with "Content-Type" "application/json" in
  let body_str = Yojson.Basic.to_string payload in
  let body = Cohttp_lwt.Body.of_string body_str in
  
  try%lwt
    let* response, _ = Cohttp_lwt_unix.Client.post ~headers ~body uri in
    let status_code = Cohttp.Response.status response |> Cohttp.Code.code_of_status in
    if status_code >= 200 && status_code < 300 then
      Logs.info (fun m -> m "Notificação enviada com sucesso para %s" url)
    else
      Logs.warn (fun m -> m "Falha ao notificar %s - Status: %d" url status_code);
    Lwt.return_unit
  with
  | exn ->
      Logs.err (fun m -> m "Erro ao notificar %s: %s" url (Printexc.to_string exn));
      Lwt.return_unit