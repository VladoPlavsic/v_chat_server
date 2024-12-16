defmodule VChatServer.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :v_chat_server,
    adapter: Ecto.Adapters.Postgres
end
