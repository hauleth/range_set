# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule RangeSet do
  import Kernel, except: [max: 2, min: 2]

  defstruct ranges: []

  @opaque ranges() :: [Range.t()]
  @type t() :: %__MODULE__{ranges: ranges()}

  @doc """
  Create new empty set.
  """
  @spec new() :: t()
  def new(), do: %__MODULE__{}

  @spec new(Range.t()) :: t()
  @spec new(Enumerable.t(Range.t())) :: t()
  def new(%__MODULE__{} = set), do: set
  def new(a..b//1) when a <= b, do: %__MODULE__{ranges: [a..b//1]}

  # TODO: Check if values in `list` are correct
  def new(list), do: %__MODULE__{ranges: list |> Enum.sort_by(& &1.first) |> squash()}

  @doc """
  Returns the minimal element in set.

  If set is empty, the provided `empty_callback` is called.

  ### Examples

  ```elixir
  iex> #{inspect(__MODULE__)}.min(RangeSet.new([1..2, 5..10]))
  1
  ```
  """
  @spec min(t(), (() -> term())) :: integer() | term()
  def min(range_set, empty_callback \\ fn -> raise Enum.EmptyError end)

  def min(%__MODULE__{ranges: [a.._//_ | _]}, _fun), do: a
  def min(%__MODULE__{ranges: []}, fun), do: fun.()

  @doc """
  Returns the maximal element in set.

  If set is empty, the provided `empty_callback` is called.

  ### Examples

  ```elixir
  iex> #{inspect(__MODULE__)}.max(RangeSet.new([1..2, 5..10]))
  10
  ```
  """
  @spec max(t(), (() -> term())) :: integer() | term()
  def max(range_set, empty_callback \\ fn -> raise Enum.EmptyError end)

  def max(%__MODULE__{ranges: ranges}, fun) do
    case List.last(ranges) do
      _..a//1 -> a
      nil -> fun.()
    end
  end

  @doc """
  Returns set that contains all gaps needed to make the range continuous.

  ```elixir
  iex> #{inspect(__MODULE__)}.new([0..2, 6..9]) |> #{inspect(__MODULE__)}.gaps()
  #{inspect(__MODULE__)}.new([3..5])

  iex> #{inspect(__MODULE__)}.new([0..5, 6..9]) |> #{inspect(__MODULE__)}.gaps()
  #{inspect(__MODULE__)}.new([])
  ```
  """
  @spec gaps(t()) :: t()
  def gaps(%__MODULE__{ranges: [_range]}), do: %__MODULE__{ranges: []}

  def gaps(%__MODULE__{ranges: ranges}) do
    gaps =
      ranges
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(fn [_..a//1, b.._//_] -> [(a + 1)..(b - 1)] end)

    %__MODULE__{ranges: gaps}
  end

  @doc """
  Determines if set is empty.

  ```elixir
  iex> #{inspect(__MODULE__)}.empty?(#{inspect(__MODULE__)}.new())
  true
  iex> #{inspect(__MODULE__)}.empty?(#{inspect(__MODULE__)}.new(1..10))
  false
  ```
  """
  @spec empty?(t()) :: boolean()
  def empty?(%__MODULE__{ranges: ranges}), do: ranges == []

  @spec member?(t(), integer()) :: boolean()
  def member?(%__MODULE__{ranges: ranges}, value), do: Enum.any?(ranges, &(value in &1))

  @doc """
  Determines if the set is continuous (there are no gaps).
  """
  @spec continuous?(t()) :: boolean()
  def continuous?(%__MODULE__{ranges: []}), do: true
  def continuous?(%__MODULE__{ranges: [_]}), do: true
  def continuous?(%__MODULE__{ranges: _}), do: false

  @doc """
  Computes length of the all ranges combined, aka amount of unique integers in set.
  """
  @spec length(t()) :: non_neg_integer()
  def length(%__MODULE__{ranges: ranges}),
    do: Enum.reduce(ranges, 0, fn r, acc -> acc + Range.size(r) end)

  @doc """
  Returns list of values stored in set.
  """
  @spec to_list(t()) :: [integer()]
  def to_list(%__MODULE__{ranges: ranges}),
    do: Enum.flat_map(ranges, & &1)

  @doc """
  Returns difference between sets.
  """
  @spec difference(t(), t() | integer() | Range.t() | [integer()]) :: t()
  def difference(range_set, other)

  def difference(%__MODULE__{} = set, int) when is_integer(int), do: difference(set, int..int)

  def difference(%__MODULE__{ranges: ranges}, c..d//1) when c <= d do
    new_ranges =
      Enum.flat_map(ranges, fn a..b//1 ->
        cond do
          a in c..d and b in c..d -> []
          a < c and b in c..d -> [a..(c - 1)]
          a in c..d and b > d -> [(d + 1)..b]
          c > a and d < b -> [a..(c - 1), (d + 1)..b]
          true -> [a..b]
        end
      end)

    %__MODULE__{ranges: new_ranges}
  end

  def difference(%__MODULE__{} = set, %__MODULE__{ranges: ranges}),
    do: Enum.reduce(ranges, set, &difference(&2, &1))

  @doc """
  Adds new value to set.
  """
  @spec put(t(), integer() | Range.t()) :: t()
  def put(range_set, value)

  def put(set, int) when is_integer(int), do: put(set, int..int//1)
  def put(set, a..b//-1), do: put(set, b..a//1)
  def put(%__MODULE__{} = set, a..b//1) when a > b, do: set

  def put(%__MODULE__{ranges: ranges}, a..b//1 = range) when a <= b do
    ranges =
      ranges
      |> insert_sorted([range])
      |> squash()

    %__MODULE__{ranges: ranges}
  end

  @doc """
  Returns union of sets
  """
  @spec union(t(), t()) :: t()
  def union(%__MODULE__{ranges: a}, %__MODULE__{ranges: b}) do
    # TODO: Replace it with `sorted_merge` operation
    union = insert_sorted(a, b) |> squash()

    %__MODULE__{ranges: union}
  end

  # Insertion step from insertion sort
  defp insert_sorted(val, []), do: val
  defp insert_sorted([], val), do: val

  defp insert_sorted([a.._//_ = x | rest], [b.._//_ | _] = y) when a < b,
    do: [x | insert_sorted(rest, y)]

  defp insert_sorted(rest, [y | ys]),
    do: [y | insert_sorted(rest, ys)]

  defp squash([]), do: []
  defp squash([_] = list), do: list

  defp squash([a..b//_, c..d//_ | rest]) when b >= c - 1,
    do: squash([a..Kernel.max(b, d) | rest])

  defp squash([x | rest]), do: [x | squash(rest)]

  @doc """
  Returns intersection between two sets
  """
  @spec intersection(t(), t()) :: t()
  def intersection(%__MODULE__{ranges: a}, %__MODULE__{ranges: b}) do
    %__MODULE__{ranges: do_intersection(a, b)}
  end

  # Finish
  defp do_intersection(a, b) when [] in [a, b], do: []

  # Same set
  # |---|
  # |---|
  defp do_intersection([r | xs], [r | ys]), do: [r | do_intersection(xs, ys)]

  # a---b
  #        c---d
  defp do_intersection([_a..b//_ | xs], [c.._d//_ | _] = ys) when b < c, do: do_intersection(xs, ys)

  #         a---b
  # c---d
  defp do_intersection([a.._b//_ | _] = xs, [_c..d//_ | ys]) when a > d, do: do_intersection(xs, ys)

  # a---b
  #   c---d
  defp do_intersection([a..b//1 | xs], [c..d//1 | _] = ys) when a <= c and b <= d and c <= b do
    [c..b | do_intersection(xs, ys)]
  end

  #   a---b
  # c---d
  defp do_intersection([a..b//1 | _] = xs, [c..d//1 | ys]) when a > c and b > d and a <= d do
    [a..d | do_intersection(xs, ys)]
  end

  #   a---b
  # c-------d
  defp do_intersection([a..b//1 | xs], [c..d//1 | _] = ys) when a in c..d//1 and b in c..d//1 do
    [a..b | do_intersection(xs, ys)]
  end

  # a-------b
  #   c---d
  defp do_intersection([a..b//1 | _] = xs, [c..d//1 | ys]) when c in a..b//1 and d in a..b//1 do
    [c..d | do_intersection(xs, ys)]
  end
end

defimpl Enumerable, for: RangeSet do
  def count(set), do: {:ok, @for.length(set)}

  def member?(set, value), do: {:ok, @for.member?(set, value)}

  def reduce(_set, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(set, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(set, &1, fun)}
  def reduce(%@for{ranges: []}, {:cont, acc}, _fun), do: {:done, acc}

  def reduce(%@for{ranges: [a..a//_ | rest]}, {:cont, acc}, fun) do
    reduce(%@for{ranges: rest}, fun.(a, acc), fun)
  end

  def reduce(%@for{ranges: [a..b//n | rest]}, {:cont, acc}, fun) do
    reduce(%@for{ranges: [(a + n)..b | rest]}, fun.(a, acc), fun)
  end

  # TODO: Implement that using more performant method
  def slice(%@for{ranges: [range]}), do: Enumerable.Range.slice(range)
  def slice(_), do: {:error, __MODULE__}
end

defimpl Inspect, for: RangeSet do
  import Inspect.Algebra

  @name inspect(@for)

  def inspect(%@for{ranges: ranges}, opts) do
    concat([@name, ".new(", Inspect.List.inspect(ranges, opts), ")"])
  end
end
