<!--
SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>

SPDX-License-Identifier: MIT
-->

# `RangeSet`

Simple structure for storing set of Elixir's (integer) ranges.

## Set operations (existing and planned)

- [x] `Enumberable`
- [x] `RangeSet.difference/2`
- [x] `RangeSet.gaps/1`
- [x] `RangeSet.intersection/2`
- [x] `RangeSet.union/2`

## Installation

The package can be installed by adding `range_set` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:range_set, "~> 1.0"}
  ]
end
```

Documentation available on [HexDocs](https://hexdocs.pm/range_set).
