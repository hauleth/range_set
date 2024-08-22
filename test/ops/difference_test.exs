defmodule Ops.DifferenceTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import RangeGen

  @subject RangeSet

  property "difference with itself result in empty set" do
    check all(set <- range_set()) do
      assert @subject.empty?(@subject.difference(set, set))
    end
  end

  property "difference with empty set is identity function" do
    check all(set <- range_set()) do
      assert set == @subject.difference(set, @subject.new())
    end
  end

  property "elements from the right set aren't in result" do
    check all(p <- range_set(), q <- range_set()) do
      result = @subject.difference(p, q)

      assert Enum.all?(q, &(&1 not in result))
    end
  end

  property "p ∪ (p ∖ q) = p" do
    check all(p <- range_set(), q <- range_set()) do
      diff = @subject.difference(p, q)

      assert p == @subject.union(p, diff)
    end
  end

  property "(p ∖ q) ∖ q = p ∖ q" do
    check all(p <- range_set(), q <- range_set()) do
      diff = @subject.difference(p, q)

      assert diff == @subject.difference(diff, q)
    end
  end

  property "single element `a` is treated the same as range `a..a`" do
    check all(p <- range_set(), a <- integer()) do
      diff1 = @subject.difference(p, a)
      diff2 = @subject.difference(p, a..a)

      assert diff1 == diff2
    end
  end
end
