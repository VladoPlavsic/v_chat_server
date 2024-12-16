defmodule VChatServerServerTest do
  use ExUnit.Case
  doctest VChatServer

  test "greets the world" do
    assert VChatServer.hello() == :world
  end
end
