open Opium
open Hookinator

(* Inicializar logging *)
let setup_logging () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Payment Webhook Service iniciado")

(* Função principal *)
let () =
  setup_logging ();
  Database.init_database ();
  App.empty
  |> App.post "/webhook" Handlers.webhook_handler
  |> App.get "/transactions" Handlers.list_transactions_handler
  |> App.get "/health" Handlers.health_check_handler
  |> App.delete "/clear-db" Handlers.clear_database_handler
  |> App.run_command