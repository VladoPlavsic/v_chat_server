defmodule VChatServer.Application do
  use Application

  def start(_type, _args) do
    children = [
      VChatServer.Repo,
      {VChatServer.Endpoint, []},
      {VChatServer.Connections, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: VChatServer.Application)
  end
end
