defmodule AnalyticsElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :segment,
      version: "0.2.2",
      elixir: "~> 1.0",
      deps: deps(),
      description: "analytics_elixir",
      package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:hackney, :logger, :retry, :tesla, :jason]]
  end

  # Dependencies can be Hex package
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
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.15"},
      {:jason, ">= 1.0.0"},
      {:retry, "~> 0.13"},
      {:mox, "~> 0.5", only: :test}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Stuart Eccles"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/stueccles/analytics-elixir"}
    ]
  end
end
