(lang dune 3.19)

(name hookinator)

(generate_opam_files true)

(source
 (github talesitf/hookinator))

(authors "Tales Ivalque <talesitf@al.insper.edu.br>")

(maintainers "Tales Ivalque <talesitf@al.insper.edu.br>")

(license MIT)

(documentation https://github.com/talesitf/hookinator)

(package
 (name hookinator)
 (synopsis "Serviço robusto de processamento de webhooks de pagamento")
 (description "Hookinator é um serviço desenvolvido em OCaml para processamento confiável de webhooks de pagamento, com autenticação por token, persistência SQLite e notificações automáticas.")
 (depends 
   ocaml 
   dune
   yojson
   opium
   lwt
   lwt_ppx
   cohttp-lwt-unix
   logs
   fmt
   sqlite3
   (alcotest :with-test)
   (alcotest-lwt :with-test))
 (tags
  ("webhook" "payment" "ocaml" "sqlite" "api" "microservice")))