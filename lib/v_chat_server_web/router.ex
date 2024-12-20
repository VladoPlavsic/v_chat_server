defmodule VChatServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Pong")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
