defmodule LiveEvent.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_event,
      version: "0.2.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/schrockwell/live_event"
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
      {:ex_doc, "~> 0.28.4", only: :dev},
      {:makeup_eex, "~> 0.1.1", only: :dev},
      {:floki, ">= 0.30.0", only: :test},
      {:jason, "~> 1.0", only: :test},
      {:live_isolated_component, "~> 0.6.4", only: [:test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:phoenix_live_view, "~> 0.18"}
    ]
  end

  defp docs do
    [
      main: "LiveEvent"
    ]
  end

  defp description do
    "Standardized events for LiveView"
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/schrockwell/live_event"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
