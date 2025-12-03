get "/system/health_check", to: "system#health_check"

post "/login", to: "system#login"

post "/blue_quill/process", to: "blue_quill#execute"
post "/blue_quill/chat", to: "blue_quill#chat"
