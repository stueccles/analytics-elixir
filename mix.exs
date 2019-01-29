defmodule AnalyticsElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :segment,
      version: "0.1.2",
      elixir: "~> 1.0",
      deps: deps(),
      name: "analytics_elixir",
      description: "analytics_elixir",
      package: package()
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
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:bypass, "~> 1.0", only: :test},
      {:uuid, "~> 1.1"}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Antonio Lorusso", "Fernando Hamasaki de Amorim"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/FindHotel/analytics-elixir"}
    ]
  end
end
