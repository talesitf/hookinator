open Opium
open Hookinator

let setup_logging () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Config.log_level);
  Logs.info (fun m -> m "Payment Webhook Service iniciado")

let () =
  (* Validar configuração antes de iniciar *)
  (match Config.validate_config () with
   | Ok () -> ()
   | Error msg -> 
     Printf.eprintf "Erro na configuração: %s\n" msg;
     exit 1);
  
  setup_logging ();
  Config.print_config ();
  Database.init_database ();
  
  App.empty
  |> App.post "/webhook" Handlers.webhook_handler
  |> App.get "/transactions" Handlers.list_transactions_handler
  |> App.get "/health" Handlers.health_check_handler
  |> App.delete "/clear-db" Handlers.clear_database_handler
  |> App.port Config.server_port
  |> App.run_command