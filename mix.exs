defmodule AnalyticsElixir.Mixfile do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/FindHotel/analytics-elixir"

  def project do
    [
      app: :segment,
      deps: deps(),
      description: "analytics_elixir",
      elixir: "~> 1.0",
      name: "analytics_elixir",
      package: package(),
      version: @version
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:httpoison, :logger, :poison, :uuid]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:poison, "~> 4.0"},
      {:uuid, "~> 1.1"},

      # Dev
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},

      # Test
      {:bypass, "~> 1.0", only: :test}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: [
        "Antonio Lorusso",
        "Felipe Vieira",
        "Fernando Hamasaki de Amorim",
        "Sergio Rodrigues"
      ]
    ]
  end
end
