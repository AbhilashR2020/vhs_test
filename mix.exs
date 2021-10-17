defmodule Vhs.MixProject do
  use Mix.Project

  def project do
    [
      app: :vhs,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps() ++ dev_deps(),
      elixirc_options: [warnings_as_errors: false],
      dialyzer: dialyzer(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Vhs.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:gun, "~> 1.3"},
      {:jason, "~> 1.2"},
      {:idna, "~> 6.0"},
      {:castore, "~> 0.1"},
      {:plug_cowboy, "~> 2.0"},
      {:websockex, "~> 0.4.2"}
    ]
  end

  defp aliases do
    [
      check: [
        "format --check-formatted",
        "compile --force --warnings-as-errors",
        # "dialyzer",
        "credo --strict"
      ]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "_build/#{Mix.env()}",
      plt_file: {:no_warn, "_build/#{Mix.env()}/dialyzer.plt"}
    ]
  end

  defp dev_deps do
    [
      {:credo, "~> 1.5.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:mock, "~> 0.3.6", only: :test}
    ]
  end
end
