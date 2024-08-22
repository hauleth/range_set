defmodule RangeSetTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import RangeGen

  @subject RangeSet

  doctest @subject

  describe "new/1" do
    property "passing existing set is noop" do
      check all(set <- range_set()) do
        assert set == @subject.new(set)
      end
    end
  end

  describe "empty set" do
    test "empty set is empty" do
      assert @subject.empty?(@subject.new([]))
    end

    property "non-empty set is not empty" do
      check all(r <- list_of(range(), min_length: 1)) do
        refute @subject.empty?(@subject.new(r))
      end
    end
  end

  describe "min/1" do
    property "minimum is in range" do
      check all(p <- range_set(min_length: 1)) do
        min = @subject.min(p)

        assert min in p
      end
    end

    property "minimum is less than or equal to all values" do
      check all(p <- range_set(min_length: 1)) do
        min = @subject.min(p)

        assert Enum.all?(p, &(min <= &1))
      end
    end

    test "on empty callback is called" do
      ref = make_ref()

      assert ref == @subject.min(@subject.new(), fn -> ref end)
    end
  end

  describe "max/1" do
    property "maximum is in range" do
      check all(p <- range_set(min_length: 1)) do
        max = @subject.max(p)

        assert max in p
      end
    end

    property "maximum is greater than or equal to all values" do
      check all(p <- range_set(min_length: 1)) do
        max = @subject.max(p)

        assert Enum.all?(p, &(max >= &1))
      end
    end

    test "on empty callback is called" do
      ref = make_ref()

      assert ref == @subject.max(@subject.new(), fn -> ref end)
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

    property "integer after addition is in set" do
      check all(set <- range_set(), a <- integer()) do
        assert a in @subject.put(set, a)
      end
    end

    property "adding new range makes all values from that range present in set" do
      check all(set <- range_set(), r <- range()) do
        set = @subject.put(set, r)

        assert Enum.all?(r, &(&1 in set))
      end
    end

    property "adding empty range is noop" do
      check all(set <- range_set(), a..b <- range(), a != b) do
        empty = b..a//1

        assert set == @subject.put(set, empty)
      end
    end

    property "adding reverse range is same a adding it 'normally'" do
      check all(set <- range_set(), a..b = r <- range()) do
        reverse = b..a//-1

        assert @subject.put(set, reverse) == @subject.put(set, r)
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
