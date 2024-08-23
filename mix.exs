# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule RangeSet.MixProject do
  use Mix.Project

  def project do
    [
      app: :range_set,
      version: "1.0.0",
      package: [
        description: "Library providing utilities for working with non continuous sets/set ranges",
        licenses: ~w[MIT],
        links: %{
          "GitHub" => "https://github.com/hauleth/range_set"
        }
      ],
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [
        ignore_modules: [
          Inspect.RangeSet,
          Enumerable.RangeSet,
          # Test Helpers
          RangeGen
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ~w[lib test/support]
  defp elixirc_paths(_), do: ~w[lib]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 1.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
