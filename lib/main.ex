defmodule Main do
  def main(_) do
    # Start the application
    IO.puts("Starting the WebSocket server...")

    # Start the application supervisor
    {:ok, _pid} = VChatServer.Application.start(:normal, [])

    # Keep the process alive to serve WebSocket connections
    Process.sleep(:infinity)
  end
end
