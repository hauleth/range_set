# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule RangeGen do
  import ExUnitProperties, only: [gen: 1]
  import StreamData

  def range do
    gen(all(a <- integer(), b <- non_negative_integer(), do: a..(a + b)))
  end

  def range_set(options \\ []) do
    gen(all(l <- uniq_list_of(range(), options), do: RangeSet.new(l)))
  end

  def element_of(_.._ = range), do: integer(range)

  def element_of(%RangeSet{ranges: ranges}), do: integer(Enum.random(ranges))
end
