defmodule VChatServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :v_chat_server,
      version: "0.1.0",
      elixir: "~> 1.16",
      escript: escript_config(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp escript_config do
    [
      # Entry point for the escript
      main_module: Main
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.9"},
      {:plug_cowboy, "~> 2.5"},
      {:x509, "~> 0.8"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto, "~> 3.12"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
