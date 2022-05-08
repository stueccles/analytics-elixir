defmodule AnalyticsElixir.Mixfile do
  use Mix.Project

  @source_url "https://github.com/stueccles/analytics-elixir"
  @version "0.2.7"

  def project do
    [
      app: :segment,
      version: @version,
      elixir: "~> 1.0",
      deps: deps(),
      description: "analytics_elixir",
      dialyzer: [plt_add_deps: [:app_tree]],
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:hackney, :logger, :retry, :tesla, :jason, :telemetry]]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:hackney, "~> 1.15"},
      {:jason, ">= 1.0.0"},
      {:mox, "~> 0.5", only: :test},
      {:retry, "~> 0.13"},
      {:telemetry, "~> 0.4.2 or ~> 1.0"},
      {:tesla, "~> 1.2"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Stuart Eccles"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "Segment",
      api_reference: false,
      source_ref: "#{@version}",
      source_url: @source_url
    ]
  end
end
