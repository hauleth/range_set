defmodule Ops.IntersectionTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import RangeGen

  @subject RangeSet

  property "intersection with itself is identity function" do
    check all(set <- range_set()) do
      assert set == @subject.intersection(set, set)
    end
  end

  property "intersection with superset is identity function" do
    check all(set <- range_set(), not @subject.empty?(set)) do
      min = @subject.min(set)
      max = @subject.max(set)

      superset = @subject.new((min - 1)..(max + 1))

      assert set == @subject.intersection(set, superset)
    end
  end

  property "with empty set result in empty set" do
    check all(set <- range_set()) do
      assert @subject.empty?(@subject.intersection(set, @subject.new()))
    end
  end

  property "is commutative" do
    check all(p <- range_set(), q <- range_set()) do
      assert @subject.intersection(q, p) == @subject.intersection(p, q)
    end
  end

  property "element of left set is member of intersection if it is also member of right set" do
    check all(p <- range_set(), q <- range_set()) do
      inter = @subject.intersection(p, q)
      assert Enum.all?(p, &(&1 in inter == &1 in q))
    end
  end

  property "element of right set is member of intersection if it is also member of right set" do
    check all(p <- range_set(), q <- range_set()) do
      inter = @subject.intersection(p, q)
      assert Enum.all?(q, &(&1 in inter == &1 in p))
    end
  end
end
