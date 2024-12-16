defmodule VChatServer.Endpoint do
  @moduledoc false

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, options: http_options(), plug: VChatServer.Router)
    ]

    Supervisor.init(children, strategy: :one_for_one, name: VChatServer.Endpoint)
  end

  defp http_options() do
    [
      dispatch: dispatch(),
      port: 4000
    ]
  end

  defp dispatch do
    [
      {:_,
       [
         {"/chat/:username", VChatServer.Connection, []},
         {:_, Plug.Cowboy.Handler, {VChatServer.Router, []}}
       ]}
    ]
  end
end
