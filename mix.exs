defmodule RangeSet.MixProject do
  use Mix.Project

  def project do
    [
      app: :range_set,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:stream_data, "~> 0.5.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
