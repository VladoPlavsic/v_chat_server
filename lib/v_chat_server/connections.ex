defmodule VChatServer.Connections do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    children = [
      {__MODULE__.Authorization, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
