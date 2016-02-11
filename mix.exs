defmodule Grit.Mixfile do
  use Mix.Project

  def project do [
    app: :grit,
    version: "0.1.0",
    elixir: "~> 1.2",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps,
    test_coverage: [tool: ExCoveralls]
  ] end

  def application do [
    applications: [:logger, :ecto, :postgrex],
    mod: {Grit, []}
  ] end

  defp deps do [
    {:ecto, git: "git@github.com:elixir-lang/ecto.git"},
    {:postgrex, "~> 0.11.0"},
    {:excoveralls, "~> 0.4", only: :test}
  ] end
end
