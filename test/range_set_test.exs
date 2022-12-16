defmodule RangeSetTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  @subject RangeSet

  doctest @subject

  def range do
    gen(all(a <- integer(), b <- positive_integer(), do: a..(a + b - 1)))
  end

  describe "empty set" do
    test "empty set is empty" do
      assert @subject.empty?(@subject.new([]))
    end
  end

  describe "union/2" do
    property "with itself is identity function" do
      check all(r <- range()) do
        set = @subject.new(r)

        assert set == @subject.union(set, set)
      end
    end

    property "with empty set is identity function" do
      check all(r <- range()) do
        set = @subject.new(r)

        assert set == @subject.union(set, @subject.new())
      end
    end

    property "is commutative" do
      check all(r1 <- range(), r2 <- range()) do
        p = @subject.new(r1)
        q = @subject.new(r2)

        assert @subject.union(q, p) == @subject.union(p, q)
      end
    end
  end

  describe "put/2" do
    property "adding initial range is noop" do
      check all(r <- range()) do
        p = @subject.new(r)

        assert p == @subject.put(p, r)
      end
    end

    property "adding value in range is noop" do
      check all(a..b = r <- range(), i <- integer(a..b)) do
        p = @subject.new(r)

        assert p == @subject.put(p, i)
      end
    end
  end

  describe "continuous?/1" do
    property "set is continuous when there are no gaps" do
      check all(ranges <- list_of(range())) do
        p = @subject.new(ranges)

        assert @subject.continuous?(p) == @subject.empty?(@subject.gaps(p))
      end
    end
  end

  describe "member?/2" do
    property "value from range is present is set" do
      check all(a..b = r <- range(), i <- integer(a..b)) do
        p = @subject.new(r)

        assert @subject.member?(p, i)
      end
    end
  end

  describe "length/1" do
    property "for single range is equal to size of given range" do
      check all(r <- range()) do
        p = @subject.new(r)

        assert @subject.length(p) == Range.size(r)
      end
    end

    property "for list of ranges its lenght is less or equal to sum of all range sizes" do
      check all(rs <- list_of(range())) do
        p = @subject.new(rs)
        range_sizes_sum = Enum.reduce(rs, 0, & &2 + Range.size(&1))

        assert @subject.length(p) <= range_sizes_sum
      end
    end
  end

  describe "to_list/1" do
    property "equal to sorted list of all unique values from ranges" do
      check all(rs <- list_of(range())) do
        p = @subject.new(rs)
        values =
          rs
          |> Enum.flat_map(& &1)
          |> Enum.uniq()
          |> Enum.sort()

        assert @subject.to_list(p) == values
      end
    end
  end
end
