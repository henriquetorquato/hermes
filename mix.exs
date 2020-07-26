defmodule Hermes.MixProject do
  use Mix.Project

  def project do
    [
      app: :hermes,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      # escript: [
      #   main_module: Hermes
      # ],
      runtime_tools: [
        observer_backend: true
      ]
    ]
  end
end
